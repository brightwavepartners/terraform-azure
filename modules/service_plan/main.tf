locals {
  app_service_plan_name               = lower("${module.globals.resource_base_name_long}-${var.role}-${module.globals.object_type_names.app_service_plan}")
  assert_app_service_plan_name_length = length(local.app_service_plan_name) > module.globals.resource_name_max_length.app_service_plan ? file("ERROR: App Service Plan name ${local.app_service_plan_name} exceeds maximum length of ${module.globals.resource_name_max_length.app_service_plan}") : null

  # there is a setting for elastic app service plans called 'maximum_elastic_worker_count'
  # that can be set to define the macimum number of workers when scaling the plan. that
  # setting is only valid on elastic app service plans and if we try to set it when the
  # desired plan is not an elastic app service plan, an error will be thrown. to keep this
  # module usable in either case of an elastic or non-elastic plan is desired, we need to
  # know during the app service plan provisioining whether the desired plan is elastic or
  # not. if it is, go ahead and set the worker count value. if the desired plan is not
  # elastic, do not attempt to set the worker count value to prevent an error.
  is_elastic_plan = try(index(["EP1", "EP2", "EP3"], var.sku_name), -1) >= 0 ? true : false

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
resource "azurerm_service_plan" "serviceplan" {
  location                     = var.location
  maximum_elastic_worker_count = local.is_elastic_plan ? var.maximum_elastic_worker_count : null
  name                         = local.app_service_plan_name
  os_type                      = var.os_type
  resource_group_name          = var.resource_group_name
  sku_name                     = var.sku_name
  tags                         = var.tags
}

# if an auto-scale setting is defined
module "serviceplan_autoscale" {
  source = "../autoscale_setting"

  for_each = {
    for scale_setting in var.scale_settings : scale_setting.name => scale_setting
  }

  app_service_plan_id = azurerm_service_plan.serviceplan.id
  location            = var.location
  resource_group_name = var.resource_group_name
  settings            = each.value
  tags                = var.tags
}

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_service_plan.serviceplan.id
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
    name                = "${each.value.name} - ${azurerm_service_plan.serviceplan.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_service_plan.serviceplan.id
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
