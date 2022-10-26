terraform {
  experiments = [module_variable_optional_attrs]
}

# diagnostics settings
resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  for_each = {
    for setting in var.settings : setting.name => setting
  }

  name               = each.value.name
  target_resource_id = var.target_resource_id

  log_analytics_destination_type = try(each.value.destination.log_analytics_workspace.destination_type, null)
  log_analytics_workspace_id = try(each.value.destination.log_analytics_workspace.id, null)

  dynamic "log" {
    for_each = each.value.logs

    content {
      category = log.value["category"]
      enabled  = log.value["enabled"]

      retention_policy {
        days    = log.value["retention"].days
        enabled = log.value["retention"].enabled
      }
    }
  }

  dynamic "metric" {
    for_each = each.value.metrics

    content {
      category = metric.value["category"]

      retention_policy {
        days    = metric.value["retention"].days
        enabled = metric.value["retention"].enabled
      }
    }
  }  
}
