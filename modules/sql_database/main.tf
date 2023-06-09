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
  collation    = var.collation
  license_type = var.license_type
  name         = local.name
  server_id    = var.sql_server
  tags         = var.tags

  # # max_size_gb    = 4
  # # read_scale     = true
  # # sku_name       = "S0"
  # # zone_redundant = true
}
