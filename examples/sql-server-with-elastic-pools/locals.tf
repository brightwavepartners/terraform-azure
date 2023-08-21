locals {
  application = "sql"
  environment = "sbx"
  key_vault = {
    purge_protection_enabled = false
    sku                      = "standard"
  }
  location = "northcentralus"
  sql_servers = [
    {
      administrator_login = "sandboxadmin"
      elastic_pools = [
        {
          databases = [
            {
              role = "modules"
            },
            {
              role = "portal"
            }
          ]
          max_size_gb = 512
          per_database_settings = {
            min_capacity = 0.25
            max_capacity = 2
          }
          role = "platform"
          sku = {
            name     = "GP_Gen5"
            tier     = "GeneralPurpose"
            family   = "Gen5"
            capacity = 2
          }
        }
      ]
      enabled = true
      role    = "platform"
      version = "12.0"
    }
  ]
  tags   = {}
  tenant = var.tenant
  virtual_network = {
    address_space           = ["10.0.0.0/24"]
    subnet_address_prefixes = ["10.0.0.0/24"]
  }
}
