locals {
  file_share_retention_policy_command = var.retention_days == 0 ? "az storage account file-service-properties update --resource-group ${var.resource_group_name} --account-name ${var.storage_account_name} --enable-delete-retention false" : "az storage account file-service-properties update --resource-group ${var.resource_group_name} --account-name ${var.storage_account_name} --enable-delete-retention true --delete-retention-days ${var.retention_days}"
}
# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

resource "azurerm_storage_share" "file_share" {
  name                 = var.file_share_name
  storage_account_name = var.storage_account_name
  quota                = var.maximum_size
}

# there is no native setting nor even a rest api endpoint that can be used to manage the
# soft-delete setting for file shares. the only way to manage the setting is through
# the azure cli, so we are using a null resource to execute azure cli commands.

# if specified retention days is equal to 0, turn off soft-delete
resource "null_resource" "file_share_retention_policy_disable" {
  count = var.retention_days == 0 ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      az storage account file-service-properties update --resource-group ${var.resource_group_name} --account-name ${var.storage_account_name} --enable-delete-retention false
    EOT

    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    azurerm_storage_share.file_share
  ]
}

# if specified retention days is greater than 0, turn on soft-delete and set the number of retention days
resource "null_resource" "file_share_retention_policy_enable" {
  count = var.retention_days > 0 ? 1: 0

  provisioner "local-exec" {
    command = <<EOT
      az storage account file-service-properties update --resource-group ${var.resource_group_name} --account-name ${var.storage_account_name} --enable-delete-retention true --delete-retention-days ${var.retention_days}
    EOT

    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    azurerm_storage_share.file_share
  ]
}
