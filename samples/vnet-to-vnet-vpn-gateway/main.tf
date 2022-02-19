module "resource_group_one" {
    source = "./modules/resource_group"

    address_space = ["10.0.0.0/16"]
    application = local.application
    environment = local.environment
    gateway_address_prefixes = ["10.0.255.0/27"]
    location = "northcentralus"
    tenant = "tenant"
}

module "resource_group_two" {
    source = "./modules/resource_group"

    address_space = ["172.16.0.0/12"]
    application = local.application
    environment = local.environment    
    gateway_address_prefixes = ["172.16.255.0/27"]
    location = "southcentralus"
    tenant = "tenant"   
}

resource "azurerm_virtual_network_gateway_connection" "resourcegroupone_to_resourcegrouptwo" {
  name                = "resourcegroupone-to-resourcegrouptwo"
  location            = module.resource_group_one.location
  resource_group_name = module.resource_group_one.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = module.resource_group_one.virtual_network_gateway.id
  peer_virtual_network_gateway_id = module.resource_group_two.virtual_network_gateway.id

  shared_key = "4v3ry53cr371p53c5h4r3dk3y"
}

resource "azurerm_virtual_network_gateway_connection" "resourcegrouptwo_to_resourcegroupone" {
  name                = "resourcegrouptwo-to-resourcegroupone"
  location            = module.resource_group_two.location
  resource_group_name = module.resource_group_two.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = module.resource_group_two.virtual_network_gateway.id
  peer_virtual_network_gateway_id = module.resource_group_one.virtual_network_gateway.id

  shared_key = "4v3ry53cr371p53c5h4r3dk3y"
}