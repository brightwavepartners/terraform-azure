# TODO: assert that premium tier is passed in if subnet integration is enabled

# global naming conventions and resources for the primary redis cache
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# redis cache
resource "azurerm_redis_cache" "redis_cache" {
  capacity            = var.capacity
  enable_non_ssl_port = false
  family              = var.family
  location            = var.location
  minimum_tls_version = "1.2"
  name                = "${module.globals.resource_base_name_long}-${module.globals.role_names.cache}-${module.globals.object_type_names.redis_cache}"
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  # redis cache creation is a very long running operation
  timeouts {
    create = "1h"
  }
}
