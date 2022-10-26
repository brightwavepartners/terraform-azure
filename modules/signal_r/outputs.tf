output "primary_connection_string" {
  value       = azurerm_signalr_service.signalr.primary_connection_string
  description = "The connection string for the Signal R instance associated with the primary access key."
}
