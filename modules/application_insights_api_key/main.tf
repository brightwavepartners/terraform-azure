# this module requires environment variables ARM_CLIENT_SECRET, ARM_CLIENT_ID, ARM_TENANT_ID

# api key
resource "azurerm_application_insights_api_key" "api_key" {
  name                    = var.name
  application_insights_id = var.application_insights_id
  read_permissions        = var.read_permissions
  write_permissions       = var.write_permissions
}

# service principal token
#   get token from the service principal that is executing this script
#   so we can use the token in the rest call to the azure encryption engine
resource "null_resource" "service_principal_token" {
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

# data resource that gets access to the token file
data "local_file" "token" {
  filename = "${path.root}/token.txt"

  depends_on = [
    null_resource.service_principal_token
  ]
}

# encrypt the api key
data "http" "encrypted_ai_api_key" {
  url = "https://appservice-diagnostics.azurefd.net/api/appinsights/encryptkey"

  request_headers = {
    Authorization   = "Bearer ${data.local_file.token.content_base64}"
    Accept          = "application/json"
    appinsights-key = "${azurerm_application_insights_api_key.api_key.api_key}"
  }
}

# delete the content from the file used to store the user's token
#   can't just delete the file because a destroy operation that may
#   come later would fail if the file is deleted, since the data
#   source above is dependent on the file existing. to make sure
#   the token is not left around after this script is executed,
#   delete the file contents.
resource "null_resource" "clear_token_file" {
  provisioner "local-exec" {
    command = <<EOT
            New-Item -Name '${path.root}/token.txt' -ItemType File -Force
        EOT

    interpreter = [
      "pwsh",
      "-Command"
    ]
  }

  depends_on = [
    data.http.encrypted_ai_api_key
  ]
}