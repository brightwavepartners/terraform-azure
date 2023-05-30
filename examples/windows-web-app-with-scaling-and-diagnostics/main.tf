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

# service plan
module "service_plan" {
  source = "../../modules/service_plan"

  application         = local.application
  environment         = local.environment
  location            = local.location
  os_type             = local.service_plan.os_type
  resource_group_name = module.resource_group.name
  role                = local.service_plan.role
  scale_settings      = local.service_plan.scale_settings
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
  application = local.application
  application_insights = {
    enabled                        = true
    integrate_with_app_diagnostics = true
    workspace_id                   = module.log_analytics_workspace.id
  }
  diagnostics_settings = local.windows_web_app.diagnostics_settings
  environment          = local.environment
  location             = local.location
  resource_group_name  = module.resource_group.name
  role                 = local.windows_web_app.role
  tags                 = local.tags
  tenant               = local.tenant
}
