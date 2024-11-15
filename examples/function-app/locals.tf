locals {
  app_service_plan = {
    kind = "Linux"
    role = "apps1"
    sku  = "EP2"
  }
  application = "functionapp"
  environment = "sbx"
  function = {
    application_stack = {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
    role = "functionone"
    type = "Linux"
  }
  location = "westus"
  tags     = {}
  tenant   = var.tenant
}
