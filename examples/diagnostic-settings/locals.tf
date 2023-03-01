locals {
  app_service = {
    always_on = "false"
    application_insights = {
      enabled                        = true
      integrate_with_app_diagnostics = true
    }
    role = "appone"
  }
  app_service_plan = {
    os_type  = "Windows"
    role     = "apps1"
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
