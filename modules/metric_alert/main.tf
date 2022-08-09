terraform {
  experiments = [module_variable_optional_attrs]
}

resource "azurerm_monitor_metric_alert" "alert" {
  action {
    action_group_id = var.alert_settings.action.action_group_id
  }

  dynamic "criteria" {
    for_each = var.alert_settings.static_criteria == null ? [] : [1]

    content {
      aggregation      = var.alert_settings.static_criteria.aggregation
      metric_name      = var.alert_settings.static_criteria.metric_name
      metric_namespace = var.alert_settings.static_criteria.metric_namespace
      operator         = var.alert_settings.static_criteria.operator
      threshold        = var.alert_settings.static_criteria.threshold

      dynamic "dimension" {
        for_each = var.alert_settings.static_criteria.dimensions == null ? [] : var.alert_settings.static_criteria.dimensions

        content {
          name     = dimension.value["name"]
          operator = dimension.value["operator"]
          values   = dimension.value["values"]
        }
      }
    }
  }

  dynamic "dynamic_criteria" {
    for_each = var.alert_settings.dynamic_criteria == null ? [] : [1]

    content {
      aggregation              = var.alert_settings.dynamic_criteria.aggregation
      alert_sensitivity        = var.alert_settings.dynamic_criteria.alert_sensitivity
      evaluation_failure_count = var.alert_settings.dynamic_criteria.evaluation_failure_count
      evaluation_total_count   = var.alert_settings.dynamic_criteria.evaluation_total_count
      metric_name              = var.alert_settings.dynamic_criteria.metric_name
      metric_namespace         = var.alert_settings.dynamic_criteria.metric_namespace
      operator                 = var.alert_settings.dynamic_criteria.operator

      dynamic "dimension" {
        for_each = var.alert_settings.dynamic_criteria.dimensions == null ? [] : var.alert_settings.dynamic_criteria.dimensions

        content {
          name     = dimension.value["name"]
          operator = dimension.value["operator"]
          values   = dimension.value["values"]
        }
      }
    }
  }

  description         = var.alert_settings.description
  enabled             = var.alert_settings.enabled
  frequency           = var.alert_settings.frequency
  name                = var.alert_settings.name
  resource_group_name = var.alert_settings.resource_group_name
  scopes              = var.alert_settings.scopes
  severity            = var.alert_settings.severity
  tags                = var.alert_settings.tags
  window_size         = var.alert_settings.window_size
}
