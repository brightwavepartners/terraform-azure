locals {
  application = "sql"
  environment = "sbx"
  key_vault = {
    purge_protection_enabled = false
    sku = "standard"
  }
  location = "northcentralus"
  sql_servers = [
    {
      administrator_login    = "sandboxadmin"
      databases = [
        {
          role = "platform"
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
