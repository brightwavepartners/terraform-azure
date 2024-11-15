locals {
  # if the client code supplies a name, use it. otherwise, name the resource using the default naming convention.
  name = coalesce(
    var.name,
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          module.globals.role_names.notification,
          module.globals.object_type_names.signalr
        ]
      )
    )
  )
}

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
  name                   = local.name
  resource_group_name    = var.resource_group_name
  service_mode           = var.service_mode

  sku {
    name     = var.sku
    capacity = var.capacity
  }

  tags = var.tags
}

# signalr replica(s)
#  at the time of this writing, there is no native terraform support for provisioning
#  replicas. the azapi is used here instead.
resource "azapi_resource" "signalr_replicas" {
  for_each = {
    for replica in var.replicas : replica.location => replica
  }

  type      = "Microsoft.SignalRService/signalR/replicas@2024-04-01-preview"
  parent_id = azurerm_signalr_service.signalr.id
  name = coalesce(
    each.value.name,
    replace(
      local.name,
      module.globals.location_short_name_list[var.location],
      module.globals.location_short_name_list[each.value.location]
    )
  )
  location = each.value.location
  body = {
    sku = {
      name     = try(each.value.sku.name, var.sku)          # if sku name is not defined for the replica, use the same sku as the primary
      capacity = try(each.value.sku.capacity, var.capacity) # if capacity is not defined for the replica, use the same capacity as the primay
    }
  }

  depends_on = [
    azurerm_signalr_service.signalr
  ]
}
