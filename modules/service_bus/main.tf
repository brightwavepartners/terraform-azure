terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  metric_namespace = "Microsoft.ServiceBus/namespaces"
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# queues
module "queues" {
  source = "./queue"

  for_each = {
    for queue in var.queues : queue.name => queue
  }

  namespace_id = azurerm_servicebus_namespace.service_bus.id
  queue        = each.value
}

# service bus
resource "azurerm_servicebus_namespace" "service_bus" {
  name                = lower("${module.globals.resource_base_name_short}${substr(module.globals.role_names.messaging, 0, length(module.globals.resource_base_name_short) - 2)}${module.globals.object_type_names.service_bus}")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity
  tags                = var.tags
}

# topics
module "topics" {
  source = "./topic"

  for_each = {
    for topic in var.topics : topic.name => topic
  }

  namespace_id = azurerm_servicebus_namespace.service_bus.id
  topic        = each.value
}

# service bus vnet integration - if enabled
resource "azurerm_servicebus_namespace_network_rule_set" "network_rule_set" {
  count = var.vnet_integration_enabled ? 1 : 0

  default_action = "Deny"
  namespace_id   = azurerm_servicebus_namespace.service_bus.id

  dynamic "network_rules" {
    for_each = var.subnet_ids

    content {
      subnet_id = network_rules.value
    }
  }

  ip_rules = var.allowed_ips
}

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_servicebus_namespace.service_bus.id
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
    name                = "${each.value.name} - ${azurerm_servicebus_namespace.service_bus.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_servicebus_namespace.service_bus.id
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
