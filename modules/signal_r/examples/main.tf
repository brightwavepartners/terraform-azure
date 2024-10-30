# resource group
module "resource_group" {
  source = "../../../modules/resource_group"

  application  = "insight"
  contributors = []
  environment  = "dev"
  location     = "northcentralus"
  readers      = []
  tags         = {}
  tenant       = "mytenant"
}

# signal r
module "signal_r" {
  source = "../"

  application               = "insight"
  capacity                  = 1
  connectivity_logs_enabled = false
  cors = {
    allowed_origins = ["*"]
  }
  environment            = "dev"
  location               = "northcentralus"
  messaging_logs_enabled = false
  resource_group_name    = module.resource_group.name
  service_mode = "Serverless"
  sku    = "Premium_P1"
  tags   = {}
  tenant = "mytenant"
}
