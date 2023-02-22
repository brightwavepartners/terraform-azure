locals {
  app_service_plan = {
    kind = "Windows"
    role = "apps1"
    sku = "EP2"
  }
  application = "private"
  environment = "sbx"
  function = {
    role            = "functionone"
    runtime_type    = "dotnet"
    runtime_version = "~4"
  }
  location = "northcentralus"
  tags     = {}
  tenant   = var.tenant
}