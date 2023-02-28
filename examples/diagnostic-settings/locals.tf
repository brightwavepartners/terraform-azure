locals {
  app_service = {
    always_on = "false"
    role      = "appone"
  }
  app_service_plan = {
    role = "apps1"
    sku_name = "P1v3"
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
