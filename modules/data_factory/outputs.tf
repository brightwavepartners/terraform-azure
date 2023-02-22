output "object_id" {
  value       = azurerm_data_factory.data_factory.identity[0].principal_id
  description = "The object identifier for the API Management resource that was created."
}

output "tenant_id" {
  value       = azurerm_data_factory.data_factory.identity[0].tenant_id
  description = "The identifier for the tenant in which the API Management resource was provisioned."
}