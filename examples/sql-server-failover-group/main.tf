# information about the principal executing this script
data "azurerm_client_config" "current" {}

# my ip address
module "utilities" {
  source = "../../modules/utilities"
}

# create resource groups for all regions
module "resource_groups" {
  source = "./resource_groups"

  for_each = {
    for region in flatten(
      [
        local.configuration.regions.primary_region,
        local.configuration.regions.auxiliary_regions
      ]
    ) :
    join(
      "-",
      [
        local.tenant,
        local.application,
        local.environment,
        region.location
      ]
    ) => region
  }

  application   = local.application
  configuration = local.configuration
  environment   = local.environment
  location      = each.value.location
  tags          = local.tags
  tenant        = local.tenant
}

# key vault
#   since key vault is automatically replicated within the region and to a
#   secondary region at least 150 miles away by microsoft, we only need to
#   create one key vault instance in the primary region and let microsoft
#   handle availability and redundancy.
module "key_vault" {
  source = "../../modules/key_vault"

  allowed_ips = [
    module.utilities.ip
  ]

  application = local.application
  environment = local.environment

  full_access_ids = [
    data.azurerm_client_config.current.object_id
  ]

  location                 = local.configuration.regions.primary_region.location
  purge_protection_enabled = local.configuration.key_vault.purge_protection_enabled
  resource_group_name      = local.primary_region_resource_group.name
  sku                      = local.configuration.key_vault.sku
  tags                     = local.tags
  tenant                   = local.tenant
}

# create regional resources that are duplicated across every region
module "resources" {
  source = "./resources"

  for_each = {
    for region in flatten(
      [
        local.configuration.regions.primary_region,
        local.configuration.regions.auxiliary_regions
      ]
    ) :
    join(
      "-",
      [
        local.tenant,
        local.application,
        local.environment,
        region.location
      ]
    ) => region
  }

  application   = local.application
  configuration = local.configuration
  environment   = local.environment
  location      = each.value.location
  resource_group_name = try(
    element(
      [
        for resource_group in module.resource_groups : resource_group.resource_group.name
        if resource_group.resource_group.location == each.value.location
      ],
      0
    ),
    null
  )
  tags                          = local.tags
  tenant                        = local.tenant
  virtual_network_address_space = each.value.virtual_network.address_space
}

# sql servers in failover group
module "sql_server_failover_group" {
  source = "../../modules/sql_server_failover_group"

  for_each = {
    for failover_group in local.configuration.sql_failover_groups : failover_group.primary_server.role => failover_group
  }  
  
  application = local.application
  environment = local.environment
  servers = each.value
  tags = local.tags
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

