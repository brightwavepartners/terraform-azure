terraform {
  experiments = [module_variable_optional_attrs]
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
      path                = each.value.health_probe.path
      protocol            = each.value.health_probe.protocol
      request_type        = each.value.health_probe.request_type
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
    for origin in flatten([
      for endpoint in var.endpoints : [
        for route in endpoint.routes : [
          for origin in route.origin_group.origins : {
            certificate_name_check_enabled = origin.certificate_name_check_enabled
            host_name                      = origin.host_name
            name                           = origin.name
            origin_group_name              = route.origin_group.name
          }
        ]
      ]
    ]) : origin.name => origin
  }

  cdn_frontdoor_origin_group_id = element(
    [
      for origin_group in azurerm_cdn_frontdoor_origin_group.origin_groups : origin_group.id
      if(
        origin_group.name == each.value.origin_group_name
      )
    ],
    0
  )
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  enabled                        = true
  host_name                      = each.value.host_name
  name                           = each.value.name
}

# routes
resource "azurerm_cdn_frontdoor_route" "routes" {
  for_each = {
    for route in flatten([
      for endpoint in var.endpoints : [
        for route in endpoint.routes : {
          endpoint_name       = endpoint.name
          name                = route.name
          origin_group_name   = route.origin_group.name
          origins             = route.origin_group.origins
          patterns_to_match   = route.patterns_to_match
          supported_protocols = route.supported_protocols
        }
      ]
    ]) : route.name => route
  }

  cdn_frontdoor_endpoint_id = element(
    [
      for endpoint in azurerm_cdn_frontdoor_endpoint.endpoints : endpoint.id
      if(endpoint.name == each.value.endpoint_name)
    ],
    0
  )
  cdn_frontdoor_origin_group_id = element(
    [
      for origin_group in azurerm_cdn_frontdoor_origin_group.origin_groups : origin_group.id
      if(origin_group.name == each.value.origin_group_name)
    ],
    0
  )
  cdn_frontdoor_origin_ids = [
    for origin in azurerm_cdn_frontdoor_origin.origins : origin.id
    if(can(index(each.value.origins.*.name, origin.name)))
  ]
  name                = each.value.name
  patterns_to_match   = each.value.patterns_to_match
  supported_protocols = each.value.supported_protocols
}

# web application firewall policy
resource "azurerm_cdn_frontdoor_firewall_policy" "firewall_policies" {
  for_each = {
    for endpoint in var.endpoints : endpoint.name => endpoint.security_policy.web_application_firewall_policy
  }

  mode                = each.value.mode
  name                = each.value.name
  resource_group_name = var.resource_group_name
  sku_name            = each.value.sku_name
}

# security policy
resource "azurerm_cdn_frontdoor_security_policy" "security_policies" {
  for_each = {
    for endpoint in var.endpoints : endpoint.name => endpoint
  }

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id
  name                     = each.value.security_policy.name

  security_policies {
    firewall {
      association {
        domain {
          cdn_frontdoor_domain_id = element(
            [
              for endpoint in azurerm_cdn_frontdoor_endpoint.endpoints : endpoint.id
              if(
                endpoint.name == each.value.name
              )
            ],
            0
          )
        }
        patterns_to_match = ["/*"]
      }
      cdn_frontdoor_firewall_policy_id = element(
        [
          for web_application_firewall_policy in azurerm_cdn_frontdoor_firewall_policy.firewall_policies : web_application_firewall_policy.id
          if(
            web_application_firewall_policy.name == each.value.security_policy.web_application_firewall_policy.name
          )
        ],
        0
      )
    }
  }
}
