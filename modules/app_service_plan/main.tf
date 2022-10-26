terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  app_service_plan_name               = lower("${module.globals.resource_base_name_long}-${var.role}-${module.globals.object_type_names.app_service_plan}")
  assert_app_service_plan_name_length = length(local.app_service_plan_name) > module.globals.resource_name_max_length.app_service_plan ? file("ERROR: App Service Plan name ${local.app_service_plan_name} exceeds maximum length of ${module.globals.resource_name_max_length.app_service_plan}") : null
  metric_namespace = "Microsoft.Web/serverFarms"
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# app service plan
resource "azurerm_app_service_plan" "appserviceplan" {
  kind                         = var.kind
  location                     = var.location
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  name                         = local.app_service_plan_name
  resource_group_name          = var.resource_group_name
  tags                         = var.tags

  sku {
    size = var.size
    tier = var.tier
  }
}

# if an auto-scale setting is defined
module "appserviceplan_autoscale" {
  source = "../autoscale_setting"

  for_each = {
      for scale_setting in var.scale_settings : scale_setting.name => scale_setting
  }

  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
  location = var.location
  resource_group_name = var.resource_group_name
  settings = each.value
  tags = var.tags
}

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_app_service_plan.appserviceplan.id
}

# alerts
module "alerts" {
  source = "../metric_alert"

  for_each = { for alert_setting in var.alert_settings : alert_setting.name => alert_setting }

  alert_settings = {
    action = {
      action_group_id = each.value.action.action_group_id
    }
    description = each.value.description
    dynamic_criteria = try(
      {
        aggregation              = each.value.dynamic_criteria.aggregation
        alert_sensitivity        = each.value.dynamic_criteria.alert_sensitivity
        evaluation_failure_count = try(each.value.dynamic_criteria.evaluation_failure_count, null)
        evaluation_total_count   = try(each.value.dynamic_criteria.evaluation_total_count, null)
        metric_name              = each.value.dynamic_criteria.metric_name
        metric_namespace         = local.metric_namespace
        operator                 = each.value.dynamic_criteria.operator
      },
      null
    )
    enabled             = each.value.enabled
    frequency           = each.value.frequency
    name                = "${each.value.name} - ${azurerm_app_service_plan.appserviceplan.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_app_service_plan.appserviceplan.id
    ]
    severity = each.value.severity
    static_criteria = try(
      {
        aggregation      = each.value.static_criteria.aggregation
        metric_name      = each.value.static_criteria.metric_name
        metric_namespace = local.metric_namespace
        operator         = each.value.static_criteria.operator
        threshold        = each.value.static_criteria.threshold
      },
      null
    )
    tags        = var.tags
    window_size = try(each.value.window_size, null)
  }
}
