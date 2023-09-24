locals {
  metric_namespace = "Microsoft.ApiManagement/service"
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# api management
resource "azurerm_api_management" "api_management" {
  location             = var.location
  name                 = "${module.globals.resource_base_name_long}-${module.globals.role_names.api}-${module.globals.object_type_names.api_management}"
  resource_group_name  = var.resource_group_name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  sku_name             = var.sku
  tags                 = var.tags
  virtual_network_type = var.virtual_network_type
  zones                = var.availability_zones

  dynamic "additional_location" {
    for_each = var.additional_locations

    content {
      location = additional_location.value["location"]

      dynamic "virtual_network_configuration" {
        for_each = additional_location.value["subnet_id"] == null ? [] : [1]

        content {
          subnet_id = additional_location.value["subnet_id"]
        }
      }
    }
  }

  dynamic "virtual_network_configuration" {
    for_each = var.virtual_network_type == "None" ? [] : [1]

    content {
      subnet_id = var.subnet_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = "2h"
    delete = "2h"
  }
}

# create an application insights instance that will be connected to api logs - if so configured
resource "azurerm_application_insights" "application_insights" {
  count = var.application_insights == null ? 0 : 1

  application_type    = "web"
  name                = "${module.globals.resource_base_name_long}-${module.globals.object_type_names.api_management}-${module.globals.object_type_names.application_insights}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  workspace_id        = var.application_insights.loganalytics_workspace_id
}

# create a logger attached to the application insights instance that will log api data - if so configured
resource "azurerm_api_management_logger" "logger" {
  count = var.application_insights == null ? 0 : 1

  name                = azurerm_application_insights.application_insights[0].name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  resource_id         = azurerm_application_insights.application_insights[0].id

  application_insights {
    instrumentation_key = azurerm_application_insights.application_insights[0].instrumentation_key
  }
}

# api logs
resource "azurerm_api_management_diagnostic" "diagnostic" {
  count = var.application_insights == null ? 0 : 1

  always_log_errors         = var.application_insights.always_log_errors
  api_management_name       = azurerm_api_management.api_management.name
  api_management_logger_id  = azurerm_api_management_logger.logger[0].id
  http_correlation_protocol = var.application_insights.http_correlation_protocol
  identifier                = "applicationinsights"
  log_client_ip             = var.application_insights.log_client_ip_address
  resource_group_name       = var.resource_group_name
  sampling_percentage       = var.application_insights.sampling_rate_percentage
  verbosity                 = var.application_insights.verbosity

  dynamic "backend_request" {
    for_each = var.application_insights.backend_request == null ? [] : [1]

    content {
      body_bytes     = var.application_insights.backend_request.payload_bytes_to_log
      headers_to_log = var.application_insights.backend_request.headers_to_log
    }
  }

  dynamic "backend_response" {
    for_each = var.application_insights.backend_response == null ? [] : [1]

    content {
      body_bytes     = var.application_insights.backend_response.payload_bytes_to_log
      headers_to_log = var.application_insights.backend_response.headers_to_log
    }
  }

  dynamic "frontend_request" {
    for_each = var.application_insights.frontend_request == null ? [] : [1]

    content {
      body_bytes     = var.application_insights.frontend_request.payload_bytes_to_log
      headers_to_log = var.application_insights.frontend_request.headers_to_log
    }
  }

  dynamic "frontend_response" {
    for_each = var.application_insights.frontend_response == null ? [] : [1]

    content {
      body_bytes     = var.application_insights.frontend_response.payload_bytes_to_log
      headers_to_log = var.application_insights.frontend_response.headers_to_log
    }
  }
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
    name                = "${each.value.name} - ${azurerm_api_management.api_management.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_api_management.api_management.id
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

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_api_management.api_management.id
}