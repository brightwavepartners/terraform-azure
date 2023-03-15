terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  # if the client code supplies a name, use it. otherwise, name the resource using the default naming convention.
  sql_server_name = coalesce(
    var.name,
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          var.role,
          module.globals.object_type_names.sql_server
        ]
      )
    )
  )
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# create a random password for the sql admin account
# -- if a key vault was provided to store the password
resource "random_password" "sql_admin_password" {
  count = var.administrator_password == null ? 1 : 0

  length  = 32
  special = true
}

# push the sql administrator password to the key vault
# -- if a key vault was provided to store the password
resource "azurerm_key_vault_secret" "sql_admin_password" {
  count = var.administrator_password == null ? 1 : 0

  content_type = "Password for local SQL administrator account on the SQL Server with name ${local.sql_server_name}"
  key_vault_id = var.key_vault
  name = join(
    "-",
    [
      module.globals.resource_base_name_long,
      local.sql_server_name,
      module.globals.object_type_names.sql_server,
      "adminpassword"
    ]
  )
  value = random_password.sql_admin_password[0].result
}

# sql server
resource "azurerm_mssql_server" "sql_server" {
  administrator_login          = var.administrator_login
  administrator_login_password = try(random_password.sql_admin_password[0].result, var.administrator_password)
  location                     = var.location
  name                         = local.sql_server_name
  resource_group_name          = var.resource_group_name
  version                      = var.sql_version
  minimum_tls_version          = "1.2" # hard-coding this value as we don't want anything less than 1.2

  dynamic "azuread_administrator" {
    for_each = var.azure_ad_administrator == null ? [] : [1]

    content {
      login_username = var.azure_ad_administrator.name
      object_id      = var.azure_ad_administrator.object_id
    }
  }

  tags = var.tags
}

# subnets allowed access to sql server
# -- if a subnet is provided
resource "azurerm_mssql_virtual_network_rule" "subnets" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }

  name      = each.value.name
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = each.value.id
}

# firewall rules
# -- if any are provided
resource "azurerm_mssql_firewall_rule" "example" {
  for_each = {
    for firewall_rule in var.firewall_rules : firewall_rule.name => firewall_rule
  }

  name             = each.value.name
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# stand-alone databases (not in an elastic pool)
module "databases" {
  source = "../sql_database"

  for_each = {
    for database in var.databases :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          database.role,
          module.globals.object_type_names.sql_database
        ]
    )) => database
  }

  application         = var.application
  environment         = var.environment
  location            = var.location
  name                = each.value.name
  resource_group_name = var.resource_group_name
  role                = each.value.role
  sql_server          = azurerm_mssql_server.sql_server.id
  tags                = var.tags
  tenant              = var.tenant
}

# elastic pool(s)
module "elastic_pools" {
  source = "../sql_elastic_pool"

  for_each = {
    for elastic_pool in var.elastic_pools :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          elastic_pool.role,
          module.globals.object_type_names.elastic_pool
        ]
    )) => elastic_pool
  }

  application           = var.application
  environment           = var.environment
  databases             = coalesce(each.value.databases, [])
  location              = var.location
  max_size_bytes        = each.value.max_size_bytes
  max_size_gb           = each.value.max_size_gb
  per_database_settings = each.value.per_database_settings
  role                  = each.value.role
  resource_group_name   = var.resource_group_name
  sku                   = each.value.sku
  sql_server = {
    id   = azurerm_mssql_server.sql_server.id
    name = azurerm_mssql_server.sql_server.name
  }
  tags   = var.tags
  tenant = var.tenant
}

