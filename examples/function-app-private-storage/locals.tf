locals {
  app_service_plan = {
    kind = "Windows"
    role = "apps1"
    sku  = "EP2"
  }
  application = "functionapp"
  environment = "sbx"
  function = {
    application_stack = {
      dotnet_version              = "v8.0"
      use_dotnet_isolated_runtime = true
    }
    role = "functionone"
  }
  location = "eastus2"
  tags     = {}
  tenant   = var.tenant
}
