locals {
  app_service_plan_name               = lower("${module.globals.resource_base_name_long}-${var.role}-${module.globals.object_type_names.app_service_plan}")
  assert_app_service_plan_name_length = length(local.app_service_plan_name) > module.globals.resource_name_max_length.app_service_plan ? file("ERROR: App Service Plan name ${local.app_service_plan_name} exceeds maximum length of ${module.globals.resource_name_max_length.app_service_plan}") : null

  profile_capacity_identifier  = "capacity"
  scale_rule_action_identifier = "action"
  scale_rules_identifier       = "rules"
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

# if an auto-scale setting is defined, setup an auto-scale plan
resource "azurerm_monitor_autoscale_setting" "appserviceplan_autoscale" {
  for_each = { for scale_setting in var.scale_settings : scale_setting.name => scale_setting }

  enabled             = each.value.enabled
  location            = var.location
  name                = each.value.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
  target_resource_id  = azurerm_app_service_plan.appserviceplan.id

  notification {
    email {
      custom_emails                         = each.value.notification.email.recipients
      send_to_subscription_administrator    = each.value.notification.email.send_to_subscription_administrator
      send_to_subscription_co_administrator = each.value.notification.email.send_to_subscription_co_administrator
    }
  }

  dynamic "profile" {
    for_each = each.value.profiles
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
            metric_resource_id = azurerm_app_service_plan.appserviceplan.id
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
