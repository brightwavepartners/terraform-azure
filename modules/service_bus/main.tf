# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
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

# service bus vnet integration - if enabled
resource "azurerm_servicebus_namespace_network_rule_set" "network_rule_set" {
  count = var.vnet_integration_enabled ? 1 : 0

  default_action      = "Deny"
  namespace_name      = azurerm_servicebus_namespace.service_bus.name
  resource_group_name = var.resource_group_name

  dynamic "network_rules" {
    for_each = var.subnet_ids

    content {
      subnet_id = network_rules.value
    }
  }

  ip_rules = var.allowed_ips
}

# TODO: need to support configurations for diagnostics (e.g. enabled/disabled, different categories, different sinks, different metrics, etc.)

# send diagnostic settings to log analytics workspace
resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  log_analytics_workspace_id = var.log_analytics_workspace_id
  name                       = "All logs and metrics to Log Analytics"
  target_resource_id         = azurerm_servicebus_namespace.service_bus.id

  log {
    category = "OperationalLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 90
    }
  }

  log {
    category = "VNetAndIPFilteringLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 90
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 90
    }
  }
}