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

# windows web app
module "windows_web_app" {
  source = "../../modules/windows_web_app"

  application = local.application
  application_insights = {
    enabled                        = local.windows_web_app.application_insights.enabled
    integrate_with_app_diagnostics = local.windows_web_app.application_insights.integrate_with_app_diagnostics
    workspace_id                   = module.log_analytics_workspace.id
  }
  application_stack   = local.windows_web_app.application_stack
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = local.windows_web_app.role
  service_plan_info = {
    id      = module.service_plan.id
    os_type = module.service_plan.os_type
  }
  tags   = local.tags
  tenant = local.tenant
}
