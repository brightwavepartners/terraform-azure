# the experimental feature for making module variables optional is enabled here to allow passing
# range or ranges values depending on the whether one range or multiple ranges are required
# in the security rule. this will produce a warning that the experimental feature is turned on
# whenever a plan/apply is executed. if/when this feature is made permanent, this flag can be
# removed.
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
}

# network security group rules
resource "azurerm_network_security_rule" "network_security_group_rules" {
  for_each = {
    for rule in var.network_security_group_rules : rule.name => rule
  }

  access                                     = each.value.access
  description                                = each.value.description
  destination_address_prefix                 = each.value.destination_address_prefix
  destination_address_prefixes               = each.value.destination_address_prefixes
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
  destination_port_range                     = each.value.destination_port_range
  destination_port_ranges                    = each.value.destination_port_ranges
  direction                                  = each.value.direction
  name                                       = each.value.name
  network_security_group_name                = azurerm_network_security_group.network_security_group.name
  priority                                   = each.value.priority
  protocol                                   = each.value.protocol
  resource_group_name                        = var.resource_group_name
  source_address_prefix                      = each.value.source_address_prefix
  source_application_security_group_ids      = each.value.source_application_security_group_ids
  source_port_range                          = each.value.source_port_range
  source_port_ranges                         = each.value.source_port_ranges
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
