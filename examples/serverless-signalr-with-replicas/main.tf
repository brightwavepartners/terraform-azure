# global naming conventions and resources
module "globals" {
  source = "../../modules/globals"

  application = local.application
  environment = local.environment
  location    = local.location
  tenant      = local.tenant
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
  tenant       = local.tenant
}

# serverless signalr
module "signalr" {
  source = "../../modules/signal_r"

  providers = {
    azapi = azapi
  }

  application               = local.application
  capacity                  = 1
  connectivity_logs_enabled = true
  cors = {
    allowed_origins = ["*"]
  }
  environment            = local.environment
  location               = local.location
  messaging_logs_enabled = true
  replicas = [
    {
      location = "southcentralus"
    },
    {
      location = "centralus",
    }
  ]
  resource_group_name = module.resource_group.name
  service_mode        = "Serverless"
  sku                 = "Premium_P1"
  tags                = {}
  tenant              = local.tenant
}
