# global naming conventions and resources
module "globals" {
  source = "../../../modules/globals"

  application = var.configuration.application
  environment = var.configuration.environment
  location    = var.location
  tenant      = var.configuration.tenant
}

# resource group
module "resource_group" {
  source = "../../../modules/resource_group"

  application  = var.configuration.application
  contributors = []
  environment  = var.configuration.environment
  location     = var.location
  readers      = []
  tags         = var.configuration.tags
  tenant       = var.configuration.tenant
}

# service plans
module "service_plans" {
  source = "../../../modules/service_plan"

  for_each = {
    for service_plan in var.configuration.service_plans :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          service_plan.role,
          module.globals.object_type_names.app_service_plan
        ]
      )
    ) => service_plan
  }

  application = var.configuration.application
  environment         = var.configuration.environment
  location            = var.location
  os_type             = each.value.os_type
  resource_group_name = module.resource_group.name
  role                = each.value.role
  sku_name = each.value.sku_name
  tags     = var.configuration.tags
  tenant   = var.configuration.tenant
}

# apps
module "apps" {
  source = "../../../modules/windows_web_app"

  for_each = {
    for app in var.configuration.apps :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          app.role,
          module.globals.object_type_names.app_service
        ]
      )
    ) => app
  }

  application = var.configuration.application
  environment         = var.configuration.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  role                = each.value.role

  service_plan_info = {
    id = element(
      [
        for service_plan in module.service_plans : service_plan.id
        if can(
          regex(
            lower(
              each.value.service_plan_role
            ),
            service_plan.name
          )
        )
      ], 0
    )
    os_type = element(
      [
        for service_plan in module.service_plans : service_plan.os_type
        if can(
          regex(
            lower(
              each.value.service_plan_role
            ),
            service_plan.name
          )
        )
      ], 0
    )
  }

  tags                      = var.configuration.tags
  tenant                    = var.configuration.tenant
}

