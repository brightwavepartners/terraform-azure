# the experimental feature for making module variables optional is enabled here to allow passing
# range or ranges values depending on the whether one range or multiple ranges are required
# in the security rule. this will produce a warning that the experimental feature is turned on
# whenever a plan/apply is executed. if/when this feature is made permanent, this flag can be
# removed.
terraform {
  experiments = [module_variable_optional_attrs]
}

module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# network security group
resource "azurerm_network_security_group" "network_security_group" {
  location            = var.location
  name                = "${module.globals.resource_base_name_long}-${lower(var.role)}-${module.globals.object_type_names.network_security_group}"
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # TODO: security rules need to be done outside of the "azurerm_network_security_group" resource because any updates
  #       to the list of security rules in the network security group via standalone security rules in some other place
  #       will cause terraform to want to destroy the stand alone rules. you can't mix and match inline and stand alone
  #       rules definitions per the NOTE at the top of the page here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
  # TODO: this needs to be done via a for loop instead of a dynamic block, but that will currently destroy some of the
  #       of the rules that are needed for the sql managed instance, which we don't want. see the comment for ip_restrictions
  #       in the function_app resource "azurerm_function_app" "function_app" for discussion about why the for loop is needed.
  dynamic "security_rule" {
    for_each = var.network_security_group_rules

    content {
      access                                     = security_rule.value["access"]
      description                                = security_rule.value["description"]
      destination_address_prefix                 = security_rule.value["destination_address_prefix"]
      destination_address_prefixes               = security_rule.value["destination_address_prefixes"]
      destination_application_security_group_ids = security_rule.value["destination_application_security_group_ids"]
      destination_port_range                     = security_rule.value["destination_port_range"]
      destination_port_ranges                    = security_rule.value["destination_port_ranges"]
      direction                                  = security_rule.value["direction"]
      name                                       = security_rule.value["name"]
      priority                                   = security_rule.value["priority"]
      protocol                                   = security_rule.value["protocol"]
      source_address_prefix                      = security_rule.value["source_address_prefix"]
      source_application_security_group_ids      = security_rule.value["source_application_security_group_ids"]
      source_port_range                          = security_rule.value["source_port_range"]
      source_port_ranges                         = security_rule.value["source_port_ranges"]
    }
  }

  # TODO: we are ignoring security_rules changes due to the issue with mixing and matching inline and stand alone rules definitions
  lifecycle {
    ignore_changes = [
      security_rule
    ]
  }
}

# subnet
resource "azurerm_subnet" "subnet" {
  address_prefixes     = var.address_prefixes
  name                 = var.name
  resource_group_name  = var.virtual_network_resource_group_name
  virtual_network_name = var.virtual_network_name

  dynamic "delegation" {
    for_each = var.delegation == null ? [] : [1]

    content {
      name = var.delegation.name

      service_delegation {
        actions = var.delegation.service_delegation.actions
        name    = var.delegation.service_delegation.name
      }
    }
  }

  service_endpoints = var.service_endpoints
}

# associate the subnet with the network security group
resource "azurerm_subnet_network_security_group_association" "network_security_group_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}
