terraform {
  experiments = [module_variable_optional_attrs]
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# elastic pools
resource "azurerm_mssql_elasticpool" "elastic_pool" {
  license_type = var.license_type # if a value is not supplied, it will be null here and will default to "LicenseIncluded"
  location     = var.location
  max_size_gb  = var.max_size_gb != null ? var.max_size_gb : var.max_size_bytes / 1000000000
  name = coalesce(
    var.name,
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          var.role,
          module.globals.object_type_names.elastic_pool
        ]
      )
    )
  )
  per_database_settings {
    max_capacity = var.per_database_settings.max_capacity
    min_capacity = var.per_database_settings.min_capacity
  }
  resource_group_name = var.resource_group_name
  server_name         = var.sql_server.name
  sku {
    capacity = var.sku.capacity
    family   = var.sku.family
    name     = var.sku.name
    tier     = var.sku.tier
  }
}

# elastic pool databases
module "elastic_databases" {
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
  elastic_pool        = azurerm_mssql_elasticpool.elastic_pool.id
  environment         = var.environment
  location            = var.location
  name                = each.value.name
  resource_group_name = var.resource_group_name
  role                = each.value.role
  sql_server          = var.sql_server.id
  tags                = var.tags
  tenant              = var.tenant
}