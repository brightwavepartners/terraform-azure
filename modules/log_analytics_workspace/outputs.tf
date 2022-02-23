output "id" {
  value       = azurerm_log_analytics_workspace.log_analytics.id
  description = "The Azure resource identifier for the Log Analytics Workspace."
}

output "name" {
  value       = azurerm_log_analytics_workspace.log_analytics.name
  description = "The name that was assigned to the Log Analytics Workspace when it was provisioned."
}

output "primary_shared_key" {
  value       = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
  description = "The primary shared key for access to the Log Analytics Workspace."
}