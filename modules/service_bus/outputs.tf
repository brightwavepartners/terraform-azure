output "id" {
  value       = azurerm_servicebus_namespace.service_bus.id
  description = "The Azure resource identifier of the Service Bus."
}

output "name" {
  value       = azurerm_servicebus_namespace.service_bus.name
  description = "The name that was assigned to the service bus when it was provisioned."
}

output "primary_connection_string" {
  value       = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
  description = "The primary connection string needed to gain access to the Service Bus."
}