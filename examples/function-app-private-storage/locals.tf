locals {
  app_service_plan = {
    kind = "Windows"
    role = "apps1"
    sku  = "EP2"
  }
  application = "private"
  environment = "sbx"
  function = {
    application_stack = {
      dotnet_version = "7"
      use_dotnet_isolated_runtime = false
    }
    role            = "functionone"
  }
  location = "northcentralus"
  tags     = {}
  tenant   = var.tenant
}
