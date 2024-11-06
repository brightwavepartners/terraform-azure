# create resource groups for all regions
module "regions" {
  source = "./modules/region"

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

  virtual_network_address_space = each.value.virtual_network.address_space
  configuration                 = local.configuration
  location                      = each.value.location
}