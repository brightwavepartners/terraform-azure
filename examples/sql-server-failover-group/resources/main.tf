# global naming conventions and resources
module "globals" {
  source = "../../../modules/globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# virtual network
module "virtual_network" {
  source = "../../../modules/virtual_network"

  address_space       = var.virtual_network_address_space
  application         = var.application
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  tenant              = var.tenant
}