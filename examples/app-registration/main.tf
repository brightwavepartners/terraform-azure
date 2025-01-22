# global naming conventions and resources
module "globals" {
  source = "../../modules/globals"

  application = local.application
  environment = local.environment
  location    = local.location
  tenant      = var.tenant
}

# resource group
module "resource_group" {
  source = "../../modules/resource_group"

  application  = local.application
  contributors = []
  environment  = local.environment
  location     = local.location
  readers      = []
  tags         = {}
  tenant       = var.tenant
}

module "key_vault" {
  source = "../../modules/key_vault"

  application         = local.application
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  sku                 = local.key_vault.sku
  tags                = {}
  tenant              = var.tenant
}

# app registration - server
module "app_registration_server" {
  source = "../../modules/app_registration"

  api = {
    identifier_uri = local.app_registration_server.api.identifier_uri
    scopes = []
  }
  key_vault_id = module.key_vault.id
  name         = local.app_registration_server.name
  web          = local.app_registration_server.web
}
