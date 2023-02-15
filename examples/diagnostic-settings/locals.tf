locals {
  app_service = {
    always_on = "false"
    role      = "appone"
  }
  app_service_plan = {
    kind = "Windows"
    role = "apps1"
    size = "F1"
    tier = "Free"
  }
  application = "diagnostics"
  environment = "loc"
  location    = "northcentralus"
  log_analytics_workspace = {
    retention_period = 30
    sku              = "PerGB2018"
  }
  tags   = {}
  tenant = var.tenant
}
