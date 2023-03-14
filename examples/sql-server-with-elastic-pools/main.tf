data "azurerm_client_config" "current" {}

# global naming conventions and resources
module "globals" {
  source = "../../modules/globals"

  application = local.application
  environment = local.environment
  location    = local.location
  tenant      = local.tenant
}

# my ip address
module "utilities" {
  source = "../../modules/utilities"
}

# resource group
module "resource_group" {
  source = "../../modules/resource_group"

  application = local.application
  environment = local.environment
  location    = local.location
  tags        = local.tags
  tenant      = local.tenant
}

# virtual network
resource "azurerm_virtual_network" "virtual_network" {
  location = module.resource_group.location
  name = lower(
    join(
      "-",
      [
        module.globals.resource_base_name_long,
        module.globals.role_names.network,
        module.globals.object_type_names.virtual_network
      ]
    )
  )
  resource_group_name = module.resource_group.name
  address_space       = local.virtual_network.address_space
}

# sql subnet
module "sql_subnet" {
  source = "../../modules/subnet"

  address_prefixes = local.virtual_network.subnet_address_prefixes
  application      = local.application
  environment      = local.environment
  location         = local.location
  name = lower(
    join(
      "-",
      [
        local.application,
        module.globals.role_names.data,
        local.environment
      ]
    )
  )
  resource_group_name = module.resource_group.name
  role                = module.globals.role_names.data
  service_endpoints = [
    module.globals.resource_types.microsoft_sql
  ]
  tags                                = local.tags
  tenant                              = local.tenant
  virtual_network_name                = azurerm_virtual_network.virtual_network.name
  virtual_network_resource_group_name = azurerm_virtual_network.virtual_network.resource_group_name
}

# key vault to store sql admin password
module "key_vault" {
  source = "../../modules/key_vault"

  application = local.application
  environment = local.environment
  full_access_ids = [
    data.azurerm_client_config.current.object_id
  ]
  location                 = local.location
  purge_protection_enabled = local.key_vault.purge_protection_enabled
  resource_group_name      = module.resource_group.name
  sku                      = local.key_vault.sku
  tags                     = local.tags
  tenant                   = local.tenant
}

# sql servers
module "sql_servers" {
  source = "../../modules/sql_server"

  for_each = {
    for sql_server in local.sql_servers :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          sql_server.role,
          module.globals.object_type_names.sql_server
        ]
    )) => sql_server if sql_server.enabled
  }

  administrator_login = each.value.administrator_login
  application         = local.application
  databases           = try(each.value.databases, [])
  elastic_pools       = try(each.value.elastic_pools, [])
  environment         = local.environment
  firewall_rules = [
    {
      end_ip_address   = module.utilities.ip
      name             = data.azurerm_client_config.current.object_id
      start_ip_address = module.utilities.ip
    }
  ]
  key_vault           = module.key_vault.id
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = each.value.role
  sql_version         = each.value.version
  subnets = [
    {
      name = join(
        "-",
        [
          local.application,
          module.globals.role_names.data,
          local.environment
        ]
      )
      id = module.sql_subnet.id
    }
  ]
  tags   = local.tags
  tenant = local.tenant

  # even though this module has a reference to the key_vault module,
  # we still have to specify an explicit dependency here because
  # the access policies are applied inside the key_vault module and it
  # appears this sql_server module will attempt to start provisioning
  # before the key_vault module is fully provisioned, along with the 
  # access policies. that will result in a permissions failure since
  # the access policies aren't finished yet.
  depends_on = [
    module.key_vault
  ]
}

