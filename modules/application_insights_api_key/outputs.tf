output "api_key" {
  value = azurerm_application_insights_api_key.api_key.api_key
}

output "encrypted_api_key" {
  value = data.http.encrypted_ai_api_key.response_body
}