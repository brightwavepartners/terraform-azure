# TODO: add database creation to this
#       - what process creates the tables?
# TODO: it looks like changing the collation to SQL_Latin1_General_CI_AS_KS_WS, which is required by the insight project because of sharepoint, during creation is not supported. need to find a way to change the collation once the creation is complete.

terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  arm_template_filename = "azuredeploy.json"

  # when security group rules and route table routes are defined below, they need to be named.
  # in order to make the names meaningful and human readable, the subnet address is used in the naming.
  # unfortunately, a subnet address usually takes a form like 10.0.0.0/16 and this format will not work
  # in a security rule or route name because of the forward slash and the dots. in order to make a usable
  # name from the subnet address, the forward slash and dots are converted to dashes using two character
  # replacements.
  formatted_subnet_address = replace(replace(var.subnet_address, "/", "-"), ".", "-")

  managed_instance_name = "${module.globals.resource_base_name_long}-${module.globals.role_names.data}-${module.globals.object_type_names.sql_managed_instance}"

  network_security_group_rules = [
    {
      access                     = "Allow"
      description                = "Allow MI provisioning Control Plane Deployment and Authentication Service"
      destination_address_prefix = var.subnet_address
      destination_port_range     = null
      destination_port_ranges = [
        "1438",
        "1440",
        "1452",
        "9000",
        "9003"
      ]
      direction             = "Inbound"
      enabled               = true
      name                  = "Microsoft.Sql-managedInstances_UseOnly_mi-sqlmgmt-in-${local.formatted_subnet_address}-v10"
      priority              = 100
      protocol              = "Tcp"
      source_address_prefix = "SqlManagement"
      source_port_range     = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow MI Supportability"
      destination_address_prefix = var.subnet_address
      destination_port_range     = null
      destination_port_ranges = [
        "1440",
        "9000",
        "9003"
      ]
      direction             = "Inbound"
      enabled               = true
      name                  = "Microsoft.Sql-managedInstances_UseOnly_mi-corpsaw-in-${local.formatted_subnet_address}-v10"
      priority              = 101
      protocol              = "Tcp"
      source_address_prefix = "CorpNetSaw"
      source_port_range     = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow MI Supportability through Corpnet ranges"
      destination_address_prefix = var.subnet_address
      destination_port_range     = null
      destination_port_ranges = [
        "9000",
        "9003"
      ]
      direction             = "Inbound"
      enabled               = true
      name                  = "Microsoft.Sql-managedInstances_UseOnly_mi-corppublic-in-${local.formatted_subnet_address}-v10"
      priority              = 102
      protocol              = "Tcp"
      source_address_prefix = "CorpNetPublic"
      source_port_range     = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow Azure Load Balancer inbound traffic"
      destination_address_prefix = var.subnet_address
      destination_port_range     = "*"
      destination_port_ranges    = null
      direction                  = "Inbound"
      enabled                    = true
      name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-healthprobe-in-${local.formatted_subnet_address}-v10"
      priority                   = 103
      protocol                   = "*"
      source_address_prefix      = "AzureLoadBalancer"
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow MI internal inbound traffic"
      destination_address_prefix = var.subnet_address
      destination_port_range     = "*"
      destination_port_ranges    = null
      direction                  = "Inbound"
      enabled                    = true
      name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-internal-in-${local.formatted_subnet_address}-v10"
      priority                   = 104
      protocol                   = "*"
      source_address_prefix      = var.subnet_address
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow inbound public endpoint connections to Managed Instance inside the virtual network"
      destination_address_prefix = "*"
      destination_port_range     = null
      destination_port_ranges = [
        "3342-3343"
      ]
      direction             = "Inbound"
      enabled               = var.allow_public_access
      name                  = "AllowPublicEndpointInbound"
      priority              = 105
      protocol              = "Tcp"
      source_address_prefix = "*"
      source_port_range     = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow inbound redirect traffic to Managed Instance inside the virtual network"
      destination_address_prefix = "*"
      destination_port_range     = null
      destination_port_ranges = [
        "11000-11999"
      ]
      direction             = "Inbound"
      enabled               = var.allow_public_access
      name                  = "AllowAdoNetInbound"
      priority              = 106
      protocol              = "Tcp"
      source_address_prefix = "*"
      source_port_range     = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow MI services outbound traffic over https"
      destination_address_prefix = "AzureCloud"
      destination_port_range     = null
      destination_port_ranges = [
        "12000",
        "443"
      ]
      direction             = "Outbound"
      enabled               = var.allow_public_access
      name                  = "Microsoft.Sql-managedInstances_UseOnly_mi-services-out-${local.formatted_subnet_address}-v10"
      priority              = 100
      protocol              = "Tcp"
      source_address_prefix = var.subnet_address
      source_port_range     = "*"
    },
    {
      access                     = "Allow"
      description                = "Allow MI internal outbound traffic"
      destination_address_prefix = var.subnet_address
      destination_port_range     = "*"
      destination_port_ranges    = null
      direction                  = "Outbound"
      enabled                    = var.allow_public_access
      name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-internal-out-${local.formatted_subnet_address}-v10"
      priority                   = 101
      protocol                   = "*"
      source_address_prefix      = var.subnet_address
      source_port_range          = "*"
    }
  ]

  # when security rules and route tables are configured, routes and rules for paired regions are
  # automatically included.
  region_pairs = {
    "northcentralus" = "southcentralus"
    "southcentralus" = "northcentralus"
    "eastus"         = "westus"
    "westus"         = "eastus"
    "eastus2"        = "centralus"
    "centralus"      = "eastus2"
    "westus2"        = "westcentralus"
    "westcentralus"  = "westus2"
  }

  route_table_routes = {
    "subnet_address" = {
      address_prefix         = var.subnet_address
      name                   = "Microsoft.Sql-managedInstances_UseOnly_subnet-${local.formatted_subnet_address}-to-vnetlocal"
      next_hop_in_ip_address = null
      next_hop_type          = "VnetLocal"
    },
    "azure_active_directory" = {
      address_prefix         = "AzureActiveDirectory"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureActiveDirectory"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "azure_cloud_location" = {
      address_prefix         = "AzureCloud.${var.location}"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureCloud.${var.location}"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "azure_cloud_region_pairs_location" = {
      address_prefix         = "AzureCloud.${local.region_pairs[var.location]}"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureCloud.${local.region_pairs[var.location]}"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "azure_monitor" = {
      address_prefix         = "AzureMonitor"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-AzureMonitor"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "corp_net_public" = {
      address_prefix         = "CorpNetPublic"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-CorpNetPublic"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "corp_net_saw" = {
      address_prefix         = "CorpNetSaw"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-CorpNetSaw"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "event_hub_location" = {
      address_prefix         = "EventHub.${var.location}"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-EventHub.${var.location}"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "event_hub_region_pairs_location" = {
      address_prefix         = "EventHub.${local.region_pairs[var.location]}"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-EventHub.${local.region_pairs[var.location]}"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "sql_management" = {
      address_prefix         = "SqlManagement"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-SqlManagement"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "storage" = {
      address_prefix         = "Storage"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-Storage"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "storage_location" = {
      address_prefix         = "Storage.${var.location}"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-Storage.${var.location}"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    },
    "storage_region_pairs_location" = {
      address_prefix         = "Storage.${local.region_pairs[var.location]}"
      name                   = "Microsoft.Sql-managedInstances_UseOnly_mi-Storage.${local.region_pairs[var.location]}"
      next_hop_in_ip_address = null
      next_hop_type          = "Internet"
    }
  }
}

# global naming conventions and resources
module "globals" {
  source = "../globals"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# network security group
#   note that the network security rules are not defined inline with the network security group, but rather
#   are defined later in separate resources. this is done because this module is also re-used by the module
#   that creates a sql managed instance failover group. a failover group needs additional security rules
#   added to the network security group, and those additional rules will be added via the 'azurerm_network_security_rule'
#   resource. unfortunately, terraform does not support mixing and matching inline security rule defintions
#   with standalone 'azurerm_network_security_rule' definitions. the inline rules will take precedence, so if
#   a terraform apply is run with inline rules, subsequent terraform apply runs will destroy any standalone
#   rules that may have been added on top of the inline rules. this issue is detailed in the NOTE section at the top
#   of the documentation page here https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group.
data "azurerm_network_security_group" "network_security_group" {
  name                = var.network_security_group_name
  resource_group_name = var.resource_group_name
}

# network security group rules
resource "azurerm_network_security_rule" "network_security_group_rules" {
  for_each = { for rule in local.network_security_group_rules : replace(rule.description, " ", "_") => rule if rule.enabled }

  access                      = each.value.access
  description                 = each.value.description
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = each.value.destination_port_range
  destination_port_ranges     = each.value.destination_port_ranges
  direction                   = each.value.direction
  name                        = each.value.name
  network_security_group_name = var.network_security_group_name
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  resource_group_name         = var.resource_group_name
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = each.value.source_port_range
}

# route table
#   note that the routes are not defined inline with the route table, but rather are defined later
#   in separate resources. this is done for the same reason indicated in the comments about the
#   network security group. see those commnents as well as the NOTE section at the top of the documentation
#   page here https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route.
resource "azurerm_route_table" "routetable" {
  name                          = "${module.globals.resource_base_name_long}-${module.globals.role_names.data}-${module.globals.object_type_names.route_table}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false
  tags                          = var.tags
}

resource "azurerm_route" "route_table_routes" {
  for_each = local.route_table_routes

  address_prefix         = each.value.address_prefix
  name                   = replace(each.value.name, " ", "_")
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
  next_hop_type          = each.value.next_hop_type
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.routetable.name
}

# associate the route table with the subnet
resource "azurerm_subnet_route_table_association" "routetableassociation" {
  subnet_id      = var.subnet_id
  route_table_id = azurerm_route_table.routetable.id
}

# create a random password for the sql administrator
resource "random_password" "password" {
  length = 16
}

# push the sql administrator password to the key vault
resource "azurerm_key_vault_secret" "keyvault_client_secret" {
  content_type = "Password for local SQL administrator account on the SQL MI with name ${local.managed_instance_name}"
  key_vault_id = var.keyvault_id
  name         = "${module.globals.resource_base_name_long}-${module.globals.role_names.data}-${module.globals.object_type_names.sql_managed_instance}-adminpassword"
  value        = random_password.password.result

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# sql vulnerability assessment requires a storage account
#   TODO: if this is a geo-replicated sql instance, vulnerability assessment settings are replicated
#         over from the primary instance and only one storage account is needed.
resource "azurerm_storage_account" "storage_account" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.location
  min_tls_version          = "TLS1_2"
  name                     = lower("${module.globals.resource_base_name_short}${substr("sqlmi", 0, length(module.globals.resource_base_name_short) - 4)}sa")
  resource_group_name      = var.resource_group_name
  tags                     = var.tags

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

# sql managed instance
resource "azurerm_resource_group_template_deployment" "sqlmi" {
  name                = "${module.globals.resource_base_name_long}-${module.globals.role_names.data}-${module.globals.object_type_names.sql_managed_instance}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = file("${path.module}/${local.arm_template_filename}")
  parameters_content = jsonencode(
    {
      "administratorPassword"     = { value = random_password.password.result }
      "administratorUsername"     = { value = var.properties.administrator_username }
      "collation"                 = { value = var.properties.collation }
      "dnsZonePartner"            = { value = var.properties.dns_zone_partner }
      "licenseType"               = { value = var.properties.license_type }
      "location"                  = { value = var.location }
      "name"                      = { value = local.managed_instance_name }
      "publicDataEndpointEnabled" = { value = var.properties.public_data_endpoint_enabled }
      "skuCapacity"               = { value = var.sku.capacity }
      "skuFamily"                 = { value = var.sku.family }
      "skuName"                   = { value = var.sku.name }
      "skuTier"                   = { value = var.sku.tier }
      "storageSize"               = { value = var.properties.storage_size_in_gb }
      "subnetId"                  = { value = var.subnet_id }
      "timezoneId"                = { value = var.properties.timezone_id }
      "vcores"                    = { value = var.properties.vcores }
    }
  )

  lifecycle {
    ignore_changes = [
      name,
      parameters_content,
      tags
    ]
  }

  timeouts {
    create = "6h"
    delete = "6h"
  }

  depends_on = [
    data.azurerm_network_security_group.network_security_group,
    azurerm_network_security_rule.network_security_group_rules,
    azurerm_route_table.routetable,
    azurerm_route.route_table_routes,
    azurerm_subnet_route_table_association.routetableassociation
  ]
}

# get the sql mi that was created by the arm deployment - used to add diagnostics settings below
data "azurerm_resources" "sql" {
  resource_group_name = var.resource_group_name
  type                = "Microsoft.Sql/managedInstances"

  depends_on = [
    azurerm_resource_group_template_deployment.sqlmi
  ]
}

# diagnostics settings
module "diagnostic_settings" {
  source = "../diagnostics_settings"

  settings           = var.diagnostics_settings
  target_resource_id = data.azurerm_resources.sql.resources[0].id
}