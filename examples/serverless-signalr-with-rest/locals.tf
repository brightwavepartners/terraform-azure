locals {
  application = "signalr"
  environment = "loc"
  location    = "northcentralus"
  log_analytics_workspace = {
    retention_period = 180
    sku              = "PerGB2018"
  }
  signalr = {
    service_mode = "Serverless"
    tier         = "Free_F1"
  }
  tags   = {}
  tenant = var.tenant
}
