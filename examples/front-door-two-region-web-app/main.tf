# create resources for all regions
module "regions" {
  source = "./region"

  for_each = {
    for region in flatten(
      [
        local.configuration.regions.primary_region,
        local.configuration.regions.auxiliary_regions
      ]
    ) :
    join(
      "-",
      [
        local.configuration.tenant,
        local.configuration.application,
        local.configuration.environment,
        region.location
      ]
    ) => region
  }

  configuration = local.configuration
  location      = each.value.location
}

# create a front door instance in the primary region
#   front door is a global resource where microsoft handles the
#   geographic redundancy. only the metadata for the resource
#   actually needs to be stored somewhere so we are putting it
#   in our primary region.
module "front_door" {
  source = "../../modules/front_door"

  application = local.configuration.application
  endpoints = [
    for endpoint in local.configuration.front_door.endpoints :
    {
      name            = endpoint.name
      security_policy = endpoint.security_policy
      routes = [
        for route in endpoint.routes :
        {
          name = route.name
          origin_group = {
            health_probe   = route.origin_group.health_probe
            load_balancing = route.origin_group.load_balancing
            name           = route.origin_group.name
            origins = [
              for origin in route.origin_group.origins :
              {
                certificate_name_check_enabled = origin.certificate_name_check_enabled
                host_name                      = origin.host_name
                name                           = origin.name
              }
            ]
          }
          patterns_to_match   = route.patterns_to_match
          supported_protocols = route.supported_protocols
        }
      ]
    }
  ]
  environment = local.configuration.environment
  location    = local.configuration.regions.primary_region.location
  resource_group_name = try(
    element(
      [
        for region_resource_group in module.regions : region_resource_group.name
        if can(
          regex(
            region_resource_group.location,
            local.configuration.regions.primary_region.location
          )
        )
      ],
      0
    ),
    null
  )
  sku_name = local.configuration.front_door.sku
  tenant   = local.configuration.tenant
}
