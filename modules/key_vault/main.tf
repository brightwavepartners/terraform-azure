# *** IMPORTANT NOTE ***
#
# there are access policies being provisioned within this module. under
# most conditions, simply having a reference to this module in your code
# will create an implicit dependency so terraform will know that this
# module needs to be created first. unfortunately, it appears that implicit
# dependency doesn't necessarily include some items internal to this module.
# specifically, the implicit dependency does not appear to wait for the
# access policies to be provisioned within this module, so you may get a
# permission error if the module that is dependant on this one is dependant
# on the access policy. the fix is to add an explicit dependency on this module
# which will force the module that is dependant on this one to wait for this
# entire module to complete.

locals {
  metric_namespace = "Microsoft.KeyVault/vaults"
}

# global naming conventions and resources
module "globals" {
  source = "github.com/brightwavepartners/terraform-azure/modules/globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# access the configuration of the azurerm provider.
data "azurerm_client_config" "current" {}

# keyvault
resource "azurerm_key_vault" "keyvault" {
  enabled_for_disk_encryption = true
  location                    = var.location
  name                        = lower("${module.globals.resource_base_name_short}${substr(module.globals.role_names.secret_management, 0, length(module.globals.resource_base_name_short) - 4)}${module.globals.object_type_names.key_vault}")
  resource_group_name         = var.resource_group_name
  purge_protection_enabled    = var.purge_protection_enabled
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku
  tags                        = var.tags

  # TODO: this technique needs to be in the documentation because we are using it in multiple places in the code
  # we are using a technique here with a dynamic block to have this module support both vnet
  # integrated and non-vnet integrated storage accounts. the dynamic block will be triggered
  # if the subnet_ids variable passed in is not null. if it is not, the storage account will
  # be integrated into the virtual network provided.
  dynamic "network_acls" {
    for_each = var.subnet_ids == null ? [] : [1]

    content {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = var.allowed_ips
      virtual_network_subnet_ids = var.subnet_ids
    }
  }
}

# add full access to the key vault for the identifiers in the full access list
resource "azurerm_key_vault_access_policy" "keyvault_full_access_users" {
  for_each = toset(var.full_access_ids)

  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}

# add secrets readonly access to the key vault for the identifiers in the secrets readonly list
resource "azurerm_key_vault_access_policy" "keyvault_secrets_readonly_users" {
  for_each = toset(var.secrets_readonly_ids)

  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = [
    "Get",
    "List"
  ]
}

# TODO: if any additional roles come along (e.g. full secrets access, keys readonly, etc.), they'll need to be added as needed to finish building out this module

# TODO: need to support configurations for diagnostics (e.g. enabled/disabled, different categories, different sinks, different metrics, etc.)

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = azurerm_key_vault.keyvault.id
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
    name                = "${each.value.name} - ${azurerm_key_vault.keyvault.name}"
    resource_group_name = var.resource_group_name
    scopes = [
      azurerm_key_vault.keyvault.id
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