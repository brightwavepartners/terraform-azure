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
#   geographic 
module "front_door" {
  source = "../../modules/front_door"

  application = local.configuration.application
  endpoints = local.configuration.front_door.endpoints
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
