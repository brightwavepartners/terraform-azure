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

# app service plan
module "app_service_plan" {
  source = "../../modules/service_plan"

  application                  = local.application
  environment                  = local.environment
  location                     = local.location
  maximum_elastic_worker_count = 1
  resource_group_name          = module.resource_group.name
  os_type                      = local.app_service_plan.kind
  role                         = local.app_service_plan.role
  sku_name                     = local.app_service_plan.sku
  tags                         = local.tags
  tenant                       = local.tenant
}

# function app
module "functions" {
  source = "../../modules/function_app"

  always_on         = false
  app_settings      = {}
  application       = local.application
  application_stack = local.function.application_stack
  cors_settings = {
    allowed_origins = [
      "https://functions.azure.com",
      "https://functions-next.azure.com",
      "https://functions-staging.azure.com"
    ],
    support_credentials = false
  }
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = local.function.role
  service_plan_id     = module.app_service_plan.id
  tags                = local.tags
  tenant              = local.tenant
  type                = local.function.type
  use_32_bit_worker   = false
}
