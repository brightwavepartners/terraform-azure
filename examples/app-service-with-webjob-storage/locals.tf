locals {
  service_plan = {
    os_type  = "Windows"
    role     = "apps1"
    sku_name = "P1v3"
  }
  application = "webjobs"
  environment = "loc"
  location    = "northcentralus"
  tags        = {}
  tenant      = var.tenant
  windows_web_app = {
    role = "appone"
    # the presence of this webjobs_storage block signals we want
    # this app service to host webjobs and so we need a storage
    # account. if the app service is not going to host webjobs,
    # just remove the webjobs_storage block. there is no enable/disable
    # flag for the webjobs_storage and it is turned on and off
    # simply through the existence of this block.
    webjobs_storage = {
      alert_settings = [],
      vnet_integration = {
        enabled = false
      }
    }
  }
}
