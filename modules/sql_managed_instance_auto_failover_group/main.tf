locals {
  # in the rules defined here, there is an identifier that is used to indicate that the address should be the address of
  # the subnet in which the sql managed instance is provisioned (i.e. local.subnet_address_identifier). the reason an
  # identifier is being used in the rule definitions, as opposed to an actual address, is because an auto-failover group
  # with two sql managed instances is being provisioined and the rules are exactly the same for both instances in the
  # auto-failover group. to setup these rules, a for_each loop is used to iterate through the rules defined here and provision
  # those rules for each instance. the issue is that the subnet address is different depending on whether the rule is being
  # applied to the primary or the secondary instance in the auto-failover group. in order to correctly swtich between the
  # primary and secondary subnet addresses and apply the correct address in the for_each loop, this indicator is used to
  # signal to the for_each loop that address needs to be dynamically set as the primary or secondary subnet address depending
  # on which one is being operated on in the for_each loop.  
  network_security_group_rules = [
    {
      access                     = "Allow"
      description                = "Allow access to data"
      destination_address_prefix = local.subnet_address_identifier
      destination_port_range     = "1433"
      destination_port_ranges    = null
      direction                  = "Inbound"
      name                       = "allow_tds_inbound_primary"
      priority                   = 1000
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow inbound redirect traffic to Managed Instance inside the virtual network"
      destination_address_prefix = local.subnet_address_identifier
      destination_port_range     = "11000-11999"
      destination_port_ranges    = null
      direction                  = "Inbound"
      name                       = "allow_redirect_inbound"
      priority                   = 1100
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow inbound geodr traffic inside the virtual network"
      destination_address_prefix = local.subnet_address_identifier
      destination_port_range     = "5022"
      destination_port_ranges    = null
      direction                  = "Inbound"
      name                       = "allow_geodr_inbound"
      priority                   = 1200
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow outbound linkedserver traffic inside the virtual network"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "1433"
      destination_port_ranges    = null
      direction                  = "Outbound"
      name                       = "allow_linkedserver_outbound"
      priority                   = 1000
      protocol                   = "Tcp"
      source_address_prefix      = local.subnet_address_identifier
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow outbound redirect traffic to Managed Instance inside the virtual network"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "11000-11999"
      destination_port_ranges    = null
      direction                  = "Outbound"
      name                       = "allow_redirect_outbound"
      priority                   = 1100
      protocol                   = "Tcp"
      source_address_prefix      = local.subnet_address_identifier
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow outbound geodr traffic inside the virtual network"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "5022"
      destination_port_ranges    = null
      direction                  = "Outbound"
      name                       = "allow_geodr_outbound"
      priority                   = 1200
      protocol                   = "Tcp"
      source_address_prefix      = local.subnet_address_identifier
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow outbound private link traffic inside the virtual network"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "443"
      destination_port_ranges    = null
      direction                  = "Outbound"
      name                       = "allow_privatelink_outbound"
      priority                   = 1300
      protocol                   = "Tcp"
      source_address_prefix      = local.subnet_address_identifier
      source_port_range          = "*"
    }
  ]
  primary_instance_identifier = "primary"
  primary_subnet_address      = var.managed_instance_properties[local.primary_instance_identifier].subnet_address
  route_table_routes = [
    {
      address_prefix = "65.55.188.0/24"
      name           = "SqlManagement_0"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "207.68.190.32/27"
      name           = "SqlManagement_1"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "13.106.78.32/27"
      name           = "SqlManagement_2"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "13.106.174.32/27"
      name           = "SqlManagement_3"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "13.106.4.96/27"
      name           = "SqlManagement_4"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "104.214.108.80/32"
      name           = "SqlManagement_5"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "52.179.184.76/32"
      name           = "SqlManagement_6"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "52.187.116.202/32"
      name           = "SqlManagement_7"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "52.177.202.6/32"
      name           = "SqlManagement_8"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "23.98.55.75/32"
      name           = "SqlManagement_9"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "23.96.178.199/32"
      name           = "SqlManagement_10"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "52.162.107.128/27"
      name           = "SqlManagement_11"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "40.74.254.227/32"
      name           = "SqlManagement_12"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "23.96.185.63/32"
      name           = "SqlManagement_13"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "65.52.59.57/32"
      name           = "SqlManagement_14"
      next_hop_type  = "Internet"
    },
    {
      address_prefix = "168.62.244.242/32"
      name           = "SqlManagement_15"
      next_hop_type  = "Internet"
    }
  ]
  secondary_instance_identifier = "secondary"
  secondary_subnet_address      = var.managed_instance_properties[local.secondary_instance_identifier].subnet_address
  subnet_address_identifier     = "SubnetAddress"
}

########################################################################
# setup the primary and secondary sql instances for the failover group #
########################################################################

# a for_each loop cannot be used to create the primary and secondary managed instances
# due to the dns_zone_partner setting. the secondary managed instance needs to know
# the dns zone of the primary managed instance during provisioning so that it can be
# placed into the same dns zone as the primary. this is a requirement for the
# auto-failover functionality to operate correctly. unfortunately, each iteration
# of a for_each loop will operate in parallel, so the dns zone value of the primary
# instance would not be known to the secondary since they are both being provisioned
# at the same time.

# sql managed instance - primary
module "sqlmi_primary" {
  source = "../sql_managed_instance"

  allow_public_access         = var.allow_public_access
  application                 = var.application
  diagnostics_settings        = var.diagnostics_settings
  environment                 = var.environment
  keyvault_id                 = var.keyvault_id
  location                    = var.managed_instance_properties.primary.location
  network_security_group_name = var.managed_instance_properties.primary.network_security_group_name
  properties = merge(
    var.sql_properties,
    { "dns_zone_partner" : "" }
  )
  resource_group_name = var.managed_instance_properties.primary.resource_group_name
  sku                 = var.sku
  subnet_address      = var.managed_instance_properties.primary.subnet_address
  subnet_id           = var.managed_instance_properties.primary.subnet_id
  tags                = var.tags
  tenant              = var.tenant
}

# sql managed instance - secondary
module "sqlmi_secondary" {
  source = "../sql_managed_instance"

  allow_public_access         = var.allow_public_access
  application                 = var.application
  diagnostics_settings        = var.diagnostics_settings
  environment                 = var.environment
  keyvault_id                 = var.keyvault_id
  location                    = var.managed_instance_properties.secondary.location
  network_security_group_name = var.managed_instance_properties.secondary.network_security_group_name
  properties = merge(
    var.sql_properties,
    { "dns_zone_partner" : data.azurerm_resources.sqlmi_primary_resource.resources[0].id }
  )
  resource_group_name = var.managed_instance_properties.secondary.resource_group_name
  sku                 = var.sku
  subnet_address      = var.managed_instance_properties.secondary.subnet_address
  subnet_id           = var.managed_instance_properties.secondary.subnet_id
  tags                = var.tags
  tenant              = var.tenant

  depends_on = [
    data.azurerm_resources.sqlmi_primary_resource
  ]
}

###########################################################################################################################
# add additional rules to the network security group to support communication between the instances in the failover group #
###########################################################################################################################

resource "azurerm_network_security_rule" "network_security_group_rules" {
  for_each = {
    for network_security_group_rule in flatten([
      for key, managed_instance in var.managed_instance_properties : [
        for network_security_group_rule in local.network_security_group_rules : {
          access                     = network_security_group_rule.access
          description                = network_security_group_rule.description
          destination_address_prefix = network_security_group_rule.destination_address_prefix
          destination_port_range     = network_security_group_rule.destination_port_range
          destination_port_ranges    = network_security_group_rule.destination_port_ranges
          direction                  = network_security_group_rule.direction
          instance                   = key # this indicates if the rule is for the primary or secondary instance
          name                       = network_security_group_rule.name
          priority                   = network_security_group_rule.priority
          protocol                   = network_security_group_rule.protocol
          resource_group_name        = managed_instance.resource_group_name
          source_address_prefix      = network_security_group_rule.source_address_prefix
          source_port_range          = network_security_group_rule.source_port_range
        }
      ]
    ]) : join("_", [network_security_group_rule.instance, network_security_group_rule.name]) => network_security_group_rule
  }

  access      = each.value.access
  description = each.value.description
  # see the note in the local rules definition above for an explanation of what is being done here with the destination_address_prefix
  destination_address_prefix = each.value.destination_address_prefix != local.subnet_address_identifier ? each.value.destination_address_prefix : each.value.instance == local.primary_instance_identifier ? local.primary_subnet_address : local.secondary_subnet_address
  destination_port_range     = each.value.destination_port_range
  destination_port_ranges    = each.value.destination_port_ranges
  direction                  = each.value.direction
  name                       = each.value.name
  # if the loop is operating on the primary instance, apply the rule to the primary network security group, otherwise apply to the secondary network security group
  network_security_group_name = each.value.instance == local.primary_instance_identifier ? var.managed_instance_properties.primary.network_security_group_name : var.managed_instance_properties.secondary.network_security_group_name
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = each.value.resource_group_name
  # see the note in the local rules definition above for an explanation of what is being done here with the source_address_prefix
  source_address_prefix = each.value.source_address_prefix != local.subnet_address_identifier ? each.value.source_address_prefix : each.value.instance == local.primary_instance_identifier ? local.primary_subnet_address : local.secondary_subnet_address
  source_port_range     = each.value.source_port_range
}

#################################################################################################################
# add additional routes to the route table to support communication between the instances in the failover group #
#################################################################################################################

resource "azurerm_route" "route_table_routes" {
  for_each = {
    for route_table_route in flatten([
      for key, managed_instance in var.managed_instance_properties : [
        for route_table_route in local.route_table_routes : {
          address_prefix      = route_table_route.address_prefix
          instance            = key # this indicates if the route is for the primary or secondary instance
          name                = route_table_route.name
          next_hop_type       = route_table_route.next_hop_type
          resource_group_name = managed_instance.resource_group_name
        }
      ]
    ]) : join("_", [route_table_route.instance, route_table_route.name]) => route_table_route
  }

  address_prefix      = each.value.address_prefix
  name                = each.value.name
  next_hop_type       = each.value.next_hop_type
  resource_group_name = each.value.resource_group_name
  route_table_name    = each.value.instance == local.primary_instance_identifier ? module.sqlmi_primary.route_table.name : module.sqlmi_secondary.route_table.name
}

#############################################################################
# setup the failover group with the primary and secondary managed instances #
#############################################################################

# access the configuration of the azurerm provider.
data "azurerm_client_config" "current" {}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.managed_instance_properties.primary.location
  tenant      = var.tenant
}

# resource information about the sql managed instance in the primary resource group - used to add the sql managed instance to the auto failover group
data "azurerm_resources" "sqlmi_primary_resource" {
  resource_group_name = var.managed_instance_properties.primary.resource_group_name
  type                = "Microsoft.Sql/managedInstances"

  depends_on = [
    module.sqlmi_primary
  ]
}

# resource information about the sql managed instance in the secondary resource group - used to add the sql managed instance to the auto failover group
data "azurerm_resources" "sqlmi_secondary_resource" {
  resource_group_name = var.managed_instance_properties.secondary.resource_group_name
  type                = "Microsoft.Sql/managedInstances"

  depends_on = [
    module.sqlmi_secondary
  ]
}

# auto-failover group between the two sql instances
resource "null_resource" "sql_failover_group" {
  provisioner "local-exec" {
    command = <<EOT
      az account set --subscription ${data.azurerm_client_config.current.subscription_id}
      az sql instance-failover-group create --mi ${data.azurerm_resources.sqlmi_primary_resource.resources[0].name} --name ${lower("${module.globals.resource_base_name_long}-${module.globals.role_names.data}-${module.globals.object_type_names.failover_group}")} --partner-mi ${data.azurerm_resources.sqlmi_secondary_resource.resources[0].name} --partner-resource-group ${var.managed_instance_properties.secondary.resource_group_name} --resource-group ${var.managed_instance_properties.primary.resource_group_name} --failover-policy Automatic --grace-period 1
    EOT

    # interpreter = ["PowerShell", "-Command"]
    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    azurerm_network_security_rule.network_security_group_rules,
    azurerm_route.route_table_routes
  ]
}
