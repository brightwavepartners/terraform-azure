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

# sql server
resource "azurerm_mssql_server" "sql_server" {
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password
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

# stand-alone databases (not in an elastic pool)
module "stand_alone_databases" {
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
  resource_group_name = var.resource_group_name
  role                = each.value.role
  sql_server          = azurerm_mssql_server.sql_server.id
  tags                = var.tags
  tenant              = var.tenant
}

# elastic pools -- if there are any defined
resource "azurerm_mssql_elasticpool" "elastic_pools" {
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
  license_type = each.value.license_type # if a value is not supplied, it will be null here and will default to "LicenseIncluded"
  location     = var.location
  max_size_gb  = each.value.max_size_gb
  name = coalesce(
    each.value.name,
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          each.value.role,
          module.globals.object_type_names.elastic_pool
        ]
      )
    )
  )
  per_database_settings {
    max_capacity = each.value.per_database_settings.max_capacity
    min_capacity = each.value.per_database_settings.min_capacity
  }
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.sql_server.name
  sku {
    capacity = each.value.sku.capacity
    family   = each.value.sku.family
    name     = each.value.sku.name
    tier     = each.value.sku.tier
  }
}

# elastic pool databases
# # module "elastic_databases" {
# #   source = "../sql_database"
# # }
