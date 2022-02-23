output "id" {
  value       = azurerm_resource_group.resource_group.id
  description = "The Azure resource identifier of the resource group."
}

output "location" {
  value       = azurerm_resource_group.resource_group.location
  description = "The Azure region in which the resource group is provisioned."
}

output "name" {
  value       = azurerm_resource_group.resource_group.name
  description = "The name of the resource group."
}