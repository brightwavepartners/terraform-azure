# global naming conventions and resources
module "globals" {
  source = "../../../modules/globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# resource group
module "resource_group" {
  source = "../../../modules/resource_group"

  application  = var.application
  contributors = []
  environment  = var.environment
  location     = var.location
  readers      = []
  tags         = var.tags
  tenant       = var.tenant
}