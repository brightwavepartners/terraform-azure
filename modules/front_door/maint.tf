terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  v = flatten([
    for endpoint in var.endpoints : [
      for route_key, route in endpoint.routes : [
        for origin in route.origin_group.origins : {
          origin_group_name = route.origin_group.name
          name = origin.name
        }
      ]
    ]
  ])
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# front door profile
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

# endpoints
resource "azurerm_cdn_frontdoor_endpoint" "endpoints" {
  for_each = { for endpoint in var.endpoints : endpoint.name => endpoint }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id
}

# origin groups
resource "azurerm_cdn_frontdoor_origin_group" "origin_groups" {
  for_each = {
    for route in flatten([
      for endpoint in var.endpoints : [
        for route in endpoint.routes : route
      ]
    ]) : route.name => route.origin_group
  }

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id

  dynamic "health_probe" {
    for_each = each.value.health_probe == null ? [] : [1]

    content {
      interval_in_seconds = each.value.health_probe.internal_in_seconds
      path = each.value.health_probe.path
      protocol = each.value.health_probe.protocol
      request_type = each.value.health_probe.request_type
    }
  }

  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }

  name = each.value.name
}

# origins
resource "azurerm_cdn_frontdoor_origin" "origins" {
  for_each = {
    for x in local.v : x.name => x
  }

  cdn_frontdoor_origin_group_id = element(
      [
        for origin_group in 
  host_name = each.value.name
}
