locals {
  application = "signalr"
  environment = "loc"
  location    = "northcentralus"
  signalr = {
    service_mode = "Serverless"
    tier         = "Free_F1"
  }
  tags   = {}
  tenant = var.tenant
}
