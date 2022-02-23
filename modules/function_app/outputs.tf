output "application_insights" {
  value       = azurerm_application_insights.application_insights
  description = "The Application Insights instance associated with the Function App."
}

output "name" {
  value       = azurerm_function_app.function_app.name
  description = "The name of the Function App."
}

output "managed_identity" {
  value       = azurerm_function_app.function_app.identity
  description = "The system managed identity associated with the Function App."
}

output "resource_group_name" {
  value       = azurerm_function_app.function_app.resource_group_name
  description = "The name of the resource group within which the Function App was provisioned."
}

output "role" {
  value       = var.role
  description = "The role that was assigned to the Function App and used in the Function App name."
}