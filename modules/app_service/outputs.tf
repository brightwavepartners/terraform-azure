output "application_insights" {
  value       = azurerm_application_insights.application_insights
  description = "The Application Insights instance associated with the App Service."
}

output "name" {
  value       = azurerm_app_service.app_service.name
  description = "The name of the App Service."
}

output "managed_identity" {
  value       = azurerm_app_service.app_service.identity
  description = "The system managed identity associated with the App Service."
}

output "resource_group_name" {
  value       = azurerm_app_service.app_service.resource_group_name
  description = "The name of the resource group within which the App Service was provisioned."
}

output "role" {
  value       = var.role
  description = "The role that was assigned to the App Service and used in the App Service name."
}