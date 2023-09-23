locals {
  metric_namespace = "Microsoft.Cache/Redis"
}

# global naming conventions and resources for the primary redis cache
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# redis cache
resource "azurerm_redis_cache" "redis_cache" {
  capacity            = var.capacity
  enable_non_ssl_port = false
  family              = var.family
  location            = var.location
  minimum_tls_version = "1.2"
  name                = "${module.globals.resource_base_name_long}-${module.globals.role_names.cache}-${module.globals.object_type_names.redis_cache}"
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  # redis cache creation is a very long running operation
  timeouts {
    create = "1h"
  }
}

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_redis_cache.redis_cache.id
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
    name                = "${each.value.name} - ${azurerm_redis_cache.redis_cache.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_redis_cache.redis_cache.id
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
