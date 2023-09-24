# api key
resource "azurerm_application_insights_api_key" "api_key" {
  name                    = var.name
  application_insights_id = var.application_insights_id
  read_permissions        = var.read_permissions
  write_permissions       = var.write_permissions
}

# encrypt the api key
data "http" "encrypted_ai_api_key" {
  url = "https://appservice-diagnostics.azurefd.net/api/appinsights/encryptkey"

  request_headers = {
    # # Authorization   = "Bearer ${data.local_file.token.content_base64}"
    Accept          = "application/json"
    appinsights-key = "${azurerm_application_insights_api_key.api_key.api_key}"
  }
}
