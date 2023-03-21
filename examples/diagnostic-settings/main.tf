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

# log analytics workspace
module "log_analytics_workspace" {
  source = "../../modules/log_analytics_workspace"

  application         = local.application
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  retention_period    = local.log_analytics_workspace.retention_period
  sku                 = local.log_analytics_workspace.sku
  tenant              = local.tenant
  tags                = local.tags
}

# app service plan
module "app_service_plan" {
  source = "../../modules/app_service_plan"

  application         = local.application
  environment         = local.environment
  location            = local.location
  os_type             = local.app_service_plan.os_type
  resource_group_name = module.resource_group.name
  role                = local.app_service_plan.role
  sku_name            = local.app_service_plan.sku_name
  tags                = local.tags
  tenant              = local.tenant
}

# app service
module "app_service" {
  source = "../../modules/app_service"

  app_service_plan_info = {
    id      = module.app_service_plan.id
    os_type = module.app_service_plan.os_type
  }
  application         = local.application
  application_insights = {
    enabled = local.app_service.application_insights.enabled
    integrate_with_app_diagnostics = local.app_service.application_insights.integrate_with_app_diagnostics
    workspace_id = module.log_analytics_workspace.id
  }
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = local.app_service.role
  tags                = local.tags
  tenant              = local.tenant
}
