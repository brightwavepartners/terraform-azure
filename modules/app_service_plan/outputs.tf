output "id" {
  value       = azurerm_app_service_plan.appserviceplan.id
  description = "The Azure resource identifier of the App Service Plan."
}

output "name" {
  value       = azurerm_app_service_plan.appserviceplan.name
  description = "The name of the App Service Plan."
}