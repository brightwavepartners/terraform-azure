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
          role = "platform"
        },
        {
          role = "modules"
        }
      ]
      enabled = true
      role    = "platform"
      version = "12.0"
    }
  ]
  tags   = {}
  tenant = var.tenant
}
