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
}

# signalr
module "signalr" {
  source = "../../modules/signal_r"

  application         = local.application
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  service_mode        = local.signalr.service_mode
  sku                 = local.signalr.tier
  tenant              = local.tenant
}

# app service plan that will host the signalr hub function app
module "app_service_plan" {
  source = "../../modules/app_service_plan"

  application         = local.application
  environment         = local.environment
  location            = local.location
  os_type             = "Windows"
  resource_group_name = module.resource_group.name
  role                = "apps1"
  sku_name            = "Y1"
  tenant              = local.tenant
}

# signalr hub function app
module "signalr_hub" {
  source = "../../modules/function_app"

  app_service_plan_id        = module.app_service_plan.id
  application                = local.application
  environment                = local.environment
  functions_runtime_version  = "~4"
  location                   = local.location
  role                       = "signalrhub"
  tenant                     = local.tenant
  resource_group_name        = module.resource_group.name
  worker_runtime_type        = "dotnet"
  log_analytics_workspace_id = module.log_analytics_workspace.id
}
