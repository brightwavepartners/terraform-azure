# TODO: assert appropriate subnets and ip rules if vnet integration is desired

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
  allow_blob_public_access = var.allow_blob_public_access
  account_replication_type = var.account_replication_type
  account_tier             = var.account_tier
  location                 = var.location
  min_tls_version          = "TLS1_2"
  name                     = lower("${module.globals.resource_base_name_short}${substr(var.role, 0, length(module.globals.resource_base_name_short) - 4)}sa") # TODO: object type name should use globals
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
