output "id" {
  value       = azurerm_service_plan.appserviceplan.id
  description = "The Azure resource identifier of the App Service Plan."
}

output "name" {
  value       = azurerm_service_plan.appserviceplan.name
  description = "The name of the App Service Plan."
}

output "os_type" {
  value       = azurerm_service_plan.appserviceplan.os_type
  description = "The operating system the App Service Plan is running on."
}