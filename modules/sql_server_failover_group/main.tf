# primary sql server in failover group
module "primary_server" {
  source = "../../modules/sql_server"

  administrator_login    = var.servers.primary_server.administrator_login
  administrator_password = var.servers.primary_server.administrator_password
  application            = var.application
  azure_ad_administrator = var.servers.primary_server.azure_ad_administrator
  databases              = var.servers.primary_server.databases
  elastic_pools          = var.servers.primary_server.elastic_pools
  environment            = var.environment
  firewall_rules         = var.servers.primary_server.firewall_rules
  key_vault_id           = var.servers.primary_server.key_vault_id
  location               = var.servers.primary_server.location
  name                   = var.servers.primary_server.name
  resource_group_name    = var.servers.primary_server.resource_group_name
  role                   = var.servers.primary_server.role
  sql_version            = var.servers.primary_server.version
  subnets                = var.servers.primary_server.subnets
  tags                   = var.tags
  tenant                 = var.tenant
}

# secondary sql server in failover group
module "secondary_server" {
  source = "../../modules/sql_server"

  administrator_login    = var.servers.secondary_server.administrator_login
  administrator_password = var.servers.secondary_server.administrator_password
  application            = var.application
  azure_ad_administrator = var.servers.secondary_server.azure_ad_administrator
  databases              = var.servers.secondary_server.databases
  elastic_pools          = var.servers.secondary_server.elastic_pools
  environment            = var.environment
  firewall_rules         = var.servers.secondary_server.firewall_rules
  key_vault_id           = var.servers.secondary_server.key_vault_id
  location               = var.servers.secondary_server.location
  name                   = var.servers.secondary_server.name
  resource_group_name    = var.servers.secondary_server.resource_group_name
  role                   = var.servers.secondary_server.role
  sql_version            = var.servers.secondary_server.version
  subnets                = var.servers.secondary_server.subnets
  tags                   = var.tags
  tenant                 = var.tenant
}

# failover group
resource "azurerm_mssql_failover_group" "failover_group" {
  name = "${var.application}-default-fog"
  databases = [
    for database in module.primary_server.databases : database.id
  ]

  partner_server {
    id = module.secondary_server.id
  }

  read_write_endpoint_failover_policy {
    mode          = var.read_write_endpoint_failover_policy.mode
    grace_minutes = var.read_write_endpoint_failover_policy.grace_minutes
  }

  server_id = module.primary_server.id
  tags      = var.tags
}
