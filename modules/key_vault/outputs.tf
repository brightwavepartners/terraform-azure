output "id" {
  value       = azurerm_key_vault.keyvault.id
  description = "The Azure resource identifier for the key vault."
}

output "name" {
  value       = azurerm_key_vault.keyvault.name
  description = "The name that was assigned to the key vault."
}

output "resource_group_name" {
  value       = azurerm_key_vault.keyvault.resource_group_name
  description = "The name of the resource group in which the key vault was provisioned."
}