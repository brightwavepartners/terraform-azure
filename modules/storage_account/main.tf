# TODO: assert appropriate subnets and ip rules if vnet integration is desired
terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  metric_namespace = "Microsoft.Storage/storageAccounts"
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# TODO: are there diagnostics logs that need to be enabled for the storage account?

# storage account
resource "azurerm_storage_account" "storage_account" {
  account_replication_type = var.account_replication_type
  account_tier             = var.account_tier
  location                 = var.location
  min_tls_version          = "TLS1_2"
  name                     = lower("${module.globals.resource_base_name_short}${substr(var.role, 0, length(module.globals.resource_base_name_short) - 4)}sa") # TODO: object type name should use globals
  public_network_access_enabled = var.public_network_access_enabled
  resource_group_name      = var.resource_group_name
  tags                     = var.tags

  blob_properties {
    dynamic "cors_rule" {
      for_each = var.blob_cors_rules

      content {
        allowed_headers    = cors_rule.value["allowed_headers"]
        allowed_methods    = cors_rule.value["allowed_methods"]
        allowed_origins    = cors_rule.value["allowed_origins"]
        exposed_headers    = cors_rule.value["exposed_headers"]
        max_age_in_seconds = cors_rule.value["max_age_in_seconds"]
      }
    }
  }

  # we are using a technique here with a dynamic block to have this module support both vnet
  # integrated and non-vnet integrated storage accounts. the dynamic block will be triggered
  # if the subnet_ids variable passed in is not null. if it is not, the storage account will
  # be integrated into the virtual network provided.
  dynamic "network_rules" {
    for_each = var.subnet_ids == null ? [] : [1]

    content {
      default_action             = "Deny"
      ip_rules                   = var.allowed_ips
      virtual_network_subnet_ids = var.subnet_ids
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
    name                = "${each.value.name} - ${azurerm_storage_account.storage_account.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_storage_account.storage_account.id
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
