# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# signal r
resource "azurerm_signalr_service" "signalr" {
  connectivity_logs_enabled = var.connectivity_logs_enabled
  dynamic "cors" {
    for_each = var.cors == null ? [] : [1]

    content {
      allowed_origins = var.cors.allowed_origins
    }
  }

  location               = var.location
  messaging_logs_enabled = var.messaging_logs_enabled
  name                   = "${module.globals.resource_base_name_long}-${module.globals.role_names.notification}-${module.globals.object_type_names.signalr}"
  resource_group_name    = var.resource_group_name
  service_mode           = var.service_mode

  sku {
    name     = var.sku
    capacity = var.capacity
  }

  tags = var.tags
}
