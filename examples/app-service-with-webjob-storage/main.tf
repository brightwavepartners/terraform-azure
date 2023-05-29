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

# service plan
module "service_plan" {
  source = "../../modules/service_plan"

  application         = local.application
  environment         = local.environment
  location            = local.location
  os_type             = local.service_plan.os_type
  resource_group_name = module.resource_group.name
  role                = local.service_plan.role
  sku_name            = local.service_plan.sku_name
  tags                = local.tags
  tenant              = local.tenant
}

# windows web application
module "windows_web_app" {
  source = "../../modules/windows_web_app"

  service_plan_info = {
    id      = module.service_plan.id
    os_type = module.service_plan.os_type
  }
  application         = local.application
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = local.windows_web_app.role
  tags                = local.tags
  tenant              = local.tenant
  webjobs_storage     = local.windows_web_app.webjobs_storage
}
