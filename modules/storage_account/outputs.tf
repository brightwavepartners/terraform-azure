output "name" {
  value       = azurerm_storage_account.storage_account.name
  description = "The name of the storage account."
}

output "primary_access_key" {
  value       = azurerm_storage_account.storage_account.primary_access_key
  description = "The primary access key that allows access to the storage account."
}

output "primary_blob_host" {
  value       = azurerm_storage_account.storage_account.primary_blob_host
  description = "The hostname, with port if applicable, for blob storage in the primary location."
}

output "primary_connection_string" {
  value       = azurerm_storage_account.storage_account.primary_connection_string
  description = "The connection string associated with the storage account primary location."
}
