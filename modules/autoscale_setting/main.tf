terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  profile_capacity_identifier  = "capacity"
  scale_rule_action_identifier = "action"
  scale_rules_identifier       = "rules"
}

# auto-scale setting
resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {
  enabled             = var.settings.enabled
  location            = var.location
  name                = var.settings.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
  target_resource_id  = var.app_service_plan_id

  notification {
    email {
      custom_emails                         = var.settings.notification.email.recipients
      send_to_subscription_administrator    = var.settings.notification.email.send_to_subscription_administrator
      send_to_subscription_co_administrator = var.settings.notification.email.send_to_subscription_co_administrator
    }
  }

  dynamic "profile" {
    for_each = var.settings.profiles

    content {
      name = profile.value["name"]
      capacity {
        default = profile.value[local.profile_capacity_identifier].default
        maximum = profile.value[local.profile_capacity_identifier].maximum
        minimum = profile.value[local.profile_capacity_identifier].minimum
      }

      dynamic "rule" {
        for_each = profile.value[local.scale_rules_identifier]

        content {
          metric_trigger {
            metric_name        = rule.value["name"]
            metric_resource_id = var.app_service_plan_id
            operator           = rule.value["operator"]
            statistic          = rule.value["statistic"]
            threshold          = rule.value["threshold"]
            time_aggregation   = rule.value["time_aggregation"]
            time_grain         = rule.value["time_grain"]
            time_window        = rule.value["time_window"]
          }
          scale_action {
            cooldown  = rule.value[local.scale_rule_action_identifier].cooldown
            direction = rule.value[local.scale_rule_action_identifier].direction
            type      = rule.value[local.scale_rule_action_identifier].type
            value     = rule.value[local.scale_rule_action_identifier].value
          }
        }
      }
    }
  }
}

# auto-scale diagnostics
module "diagnostic_settings" {
  source = "../diagnostics_settings"
  
  settings = var.settings.diagnostics_settings
  target_resource_id = azurerm_monitor_autoscale_setting.autoscale_setting.id
}