# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# api management
resource "azurerm_api_management" "api_management" {
  location             = var.location
  name                 = "${module.globals.resource_base_name_long}-${module.globals.role_names.api}-${module.globals.object_type_names.api_management}"
  resource_group_name  = var.resource_group_name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  sku_name             = var.sku
  tags                 = var.tags
  virtual_network_type = var.virtual_network_type
  zones                = var.availability_zones

  dynamic "additional_location" {
    for_each = var.additional_locations

    content {
      location = additional_location.value["location"]

      dynamic "virtual_network_configuration" {
        for_each = additional_location.value["subnet_id"] == null ? [] : [1]

        content {
          subnet_id = additional_location.value["subnet_id"]
        }
      }
    }
  }

  dynamic "virtual_network_configuration" {
    for_each = var.virtual_network_type == "None" ? [] : [1]

    content {
      subnet_id = var.subnet_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = "1h"
    delete = "1h"
  }
}