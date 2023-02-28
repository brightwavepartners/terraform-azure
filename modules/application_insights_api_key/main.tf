# application insights api key for app service diagnostics
resource "azurerm_application_insights_api_key" "read_telemetry" {
  name                    = "APPSERVICEDIAGNOSTICS_READONLYKEY_${local.app_service_name}"
  application_insights_id = azurerm_application_insights.application_insights.id
  read_permissions        = ["agentconfig", "aggregate", "api", "draft", "extendqueries", "search"]
}

# get token from the service principal so we can use the token in the rest call to the azure encryption engine
resource "null_resource" "application_insights_app_service_diagnostics" {
  provisioner "local-exec" {
    command = <<EOT
            $password = ConvertTo-SecureString -String $env:ARM_CLIENT_SECRET -AsPlainText -Force
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential ($env:ARM_CLIENT_ID, $password)
            Connect-AzAccount -ServicePrincipal -TenantId $env:ARM_TENANT_ID -Credential $Credential

            $token = Get-AzAccessToken
            $token.Token | Out-File '${path.root}/token.txt'
        EOT

    interpreter = [
      "pwsh",
      "-Command"
    ]
  }
}

# access to the token file
data "local_file" "token" {
  filename = "${path.root}/token.txt"

  depends_on = [
    null_resource.application_insights_app_service_diagnostics
  ]
}

# encrypt the api key
data "http" "encrypted_ai_api_key" {
  url = "https://appservice-diagnostics.azurefd.net/api/appinsights/encryptkey"

  request_headers = {
    Authorization   = "Bearer ${data.local_file.token.content_base64}"
    Accept          = "application/json"
    appinsights-key = "${azurerm_application_insights_api_key.read_telemetry.api_key}"
  }
}