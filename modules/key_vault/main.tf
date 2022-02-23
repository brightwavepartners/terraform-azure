# global naming conventions, resources, and other enterprise standards items
module "globals" {
  source = "github.com/brightwavepartners/terraform-azure/modules/globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# keyvault
resource "azurerm_key_vault" "keyvault" {
  enabled_for_disk_encryption = true
  location                    = var.location
  name                        = lower("${module.globals.resource_base_name_short}${substr(module.globals.role_names.secret_management, 0, length(module.globals.resource_base_name_short) - 4)}${module.globals.object_type_names.key_vault}")
  resource_group_name         = var.resource_group_name
  purge_protection_enabled    = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku
  tags                        = var.tags

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
    "backup",
    "delete",
    "deletesas",
    "get",
    "getsas",
    "list",
    "listsas",
    "purge",
    "recover",
    "regeneratekey",
    "restore",
    "set",
    "setsas",
    "update"
  ]
}

# add secrets readonly access to the key vault for the identifiers in the secrets readonly list
resource "azurerm_key_vault_access_policy" "keyvault_secrets_readonly_users" {
  for_each = toset(var.secrets_readonly_ids)

  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = [
    "get",
    "list"
  ]
}

# TODO: if any additional roles come along (e.g. full secrets access, keys readonly, etc.), they'll need to be added as needed to finish building out this module

# TODO: need to support configurations for diagnostics (e.g. enabled/disabled, different categories, different sinks, different metrics, etc.)

# if a log analytics workspace id is provided, then enable diagnostics settings and send to the workspace
resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  log_analytics_workspace_id = var.log_analytics_workspace_id
  name                       = "All logs and metrics to Log Analytics"
  target_resource_id         = azurerm_key_vault.keyvault.id

  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AuditEvent"
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