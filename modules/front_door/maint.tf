locals {
  v = flatten(
    [
      for endpoint in var.endpoints : [
        for route in endpoint.routes : {
          route_name = route.name
        }
      ]
    ]
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

resource "azurerm_cdn_frontdoor_profile" "front_door_profile" {
  name = lower(
    join(
      "-",
      [
        module.globals.resource_base_name_long,
        module.globals.role_names.front_door_profile,
        module.globals.object_type_names.function_app
      ]
    )
  )
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoints" {
  for_each = { for endpoint in var.endpoints : endpoint.name => endpoint }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_groups" {
  for_each = {
    for x in local.v : x.route_name => x
  }

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id

  load_balancing {
  }

  name = each.value.route_name
}
