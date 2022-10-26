terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
    metric_namespace = "Microsoft.DataFactory/factories"
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# access the configuration of the azurerm provider.
data "azurerm_client_config" "current" {}

# data factory
resource "azurerm_data_factory" "data_factory" {
  location            = var.location
  name                = "${module.globals.resource_base_name_long}-${module.globals.role_names.data}-${module.globals.object_type_names.data_factory}"
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "vsts_configuration" {
    for_each = var.vsts_configuration == null ? [] : [1]

    content {
      account_name = var.vsts_configuration.account_name
      branch_name = var.vsts_configuration.branch_name
      project_name = var.vsts_configuration.project_name
      repository_name = var.vsts_configuration.repository_name
      root_folder = var.vsts_configuration.root_folder
      tenant_id = data.azurerm_client_config.current.tenant_id
    }
  }

  identity {
    type = "SystemAssigned"
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
    name                = "${each.value.name} - ${azurerm_data_factory.data_factory.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_data_factory.data_factory.id
    ]
    severity = each.value.severity
    static_criteria = try(
      {
        aggregation      = each.value.static_criteria.aggregation
        dimensions       = each.value.static_criteria.dimensions
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
