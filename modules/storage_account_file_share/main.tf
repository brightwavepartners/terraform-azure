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

resource "null_resource" "file_share_retention_policy" {
  provisioner "local-exec" {
    command = <<EOT
      az storage account file-service-properties update --resource-group ${var.resource_group_name} --account-name ${var.storage_account_name} --enable-delete-retention ${var.retention_days == 0 ? false : true}
    EOT

    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    azurerm_storage_share.file_share
  ]
}

