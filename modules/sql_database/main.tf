terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  name = coalesce(
    var.name,
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          var.role,
          module.globals.object_type_names.sql_database
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

resource "azurerm_mssql_database" "database" {
  collation       = var.collation
  elastic_pool_id = var.elastic_pool
  license_type    = var.license_type
  name            = local.name
  server_id       = var.sql_server
  tags            = var.tags
}
