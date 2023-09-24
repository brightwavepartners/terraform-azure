# TODO: assert appropriate subnets and ip rules if vnet integration is desired
locals {
  # the role is used in the storage account name, but only so many characters can be
  # used from the role when we combine the role with the other tokens (e.g. tenant name,
  # application name, environment name, etc.) required in our naming convention.
  # the calculation below will add up the lengths of all the other tokens in the naming
  # convention and subtract that from the maximum length allowed for a storage account
  # name. that will give us the maximum number of characters that can be used from the role
  # in the storage account name.
  max_role_name_length = local.storage_account_name_max_length - (
    module.globals.tenant_name_max_length + module.globals.application_name_max_length + module.globals.environment_name_max_length + module.globals.location_name_max_length + length(module.globals.object_type_names.storage_account)
  )

  metric_namespace = "Microsoft.Storage/storageAccounts"

  storage_account_name_max_length = 24
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
  account_replication_type        = var.account_replication_type
  account_tier                    = var.account_tier
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  location                        = var.location
  min_tls_version                 = "TLS1_2"
  name = lower(
    "${module.globals.resource_base_name_short}${substr(var.role, 0, local.max_role_name_length)}${module.globals.object_type_names.storage_account}"
  )
  resource_group_name = var.resource_group_name
  tags                = var.tags

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
