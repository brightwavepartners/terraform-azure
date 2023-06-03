# the experimental feature for making module variables optional is enabled here to allow passing
# range or ranges values depending on the whether one range or multiple ranges are required
# in the security rule. this will produce a warning that the experimental feature is turned on
# whenever a plan/apply is executed. if/when this feature is made permanent, this flag can be
# removed.
terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  name = coalesce(
    var.name,
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          module.globals.role_names.network,
          module.globals.object_type_names.virtual_network
        ]
      )
    )
  )
}

# naming conventions and standards
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# virtual network
resource "azurerm_virtual_network" "virtual_network" {
  location            = var.location
  name                = local.name
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

