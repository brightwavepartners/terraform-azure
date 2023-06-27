data "azurerm_client_config" "current" {}

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

  application = local.application
  environment = local.environment
  location    = local.location
  tags        = local.tags
  tenant      = local.tenant
}

# service bus
module "service_bus" {
  source = "../../modules/service_bus"

  allowed_ips              = local.service_bus.allowed_ips
  application              = local.application
  capacity                 = local.service_bus.capacity
  environment              = local.environment
  location                 = local.location
  resource_group_name      = module.resource_group.name
  role_assignments         = local.service_bus.role_assignments
  sku                      = local.service_bus.sku
  subnet_ids               = local.service_bus.subnet_ids
  tenant                   = local.tenant
  tags                     = local.tags
  vnet_integration_enabled = false
}

