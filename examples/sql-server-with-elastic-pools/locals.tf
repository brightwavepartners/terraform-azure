locals {
  application = "sql"
  environment = "sbx"
  location    = "northcentralus"
  sql_servers = [
    {
      administrator_login    = "sandboxadmin"
      administrator_password = "wYZS3$z6tDDG29"
      databases = [
        {
          role = "portal"
        }
      ]
      elastic_pools = [
        # # {
        # #   per_database_settings = {
        # #     max_capacity = 2
        # #     min_capacity = 0.25
        # #   }
        # #   role = "platform"
        # #   sku = {
        # #     name     = "GP_Gen5"
        # #     tier     = "GeneralPurpose"
        # #     family   = "Gen5"
        # #     capacity = 2
        # #   }
        # # }
      ]
      enabled = true
      max_size_gb = 512
      role    = "roleone"
      version = "12.0"
    }
  ]
  tags   = {}
  tenant = var.tenant
}
