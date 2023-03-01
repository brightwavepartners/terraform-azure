locals {
  app_service = {
    role = "appone"
  }
  app_service_plan = {
    os_type  = "Windows"
    role     = "apps1"
    sku_name = "P1v3"
  }
  application = "webjobs"
  environment = "loc"
  location    = "northcentralus"
  tags   = {}
  tenant = var.tenant
}
