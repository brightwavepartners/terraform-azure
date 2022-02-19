module "northcentralus" {
    source = "./modules/region"

    address_space = ["10.0.0.0/16"]
    application = local.application
    environment = local.environment
    gateway_address_prefixes = ["10.0.255.0/27"]
    location = "northcentralus"
    peer_virtual_network_gateway_id = module.southcentralus.virtual_network_gateway.id
    tenant = local.tenant
    vpn_gateway_shared_key = local.vpn_gateway_shared_key
}

module "southcentralus" {
    source = "./modules/region"

    address_space = ["172.16.0.0/12"]
    application = local.application
    environment = local.environment    
    gateway_address_prefixes = ["172.16.255.0/27"]
    location = "southcentralus"
    peer_virtual_network_gateway_id = module.northcentralus.virtual_network_gateway.id
    tenant = local.tenant
    vpn_gateway_shared_key = local.vpn_gateway_shared_key
}

# most of the infrastructure and networking components for each region
# are created in the region module, but the virtual network gateway connections
# between the two regions can't be part of the region module because that would create
# a circular dependency between the two region modules. therefore, the connections
# are created here after both region modules are already created.


# # resource "azurerm_virtual_network_gateway_connection" "southcentralus_to_northcentralus" {
# #   name                = lower("${module.globals.resource_base_name_long}-${module.globals.role_names.network}-${module.globals.object_type_names.virtual_network}")
# #   location            = module.southcentralus.location
# #   resource_group_name = module.southcentralus.resource_group_name

# #   type                            = "Vnet2Vnet"
# #   virtual_network_gateway_id      = module.southcentralus.virtual_network_gateway.id
# #   peer_virtual_network_gateway_id = module.northcentralus.virtual_network_gateway.id

# #   shared_key = local.vpn_gateway_shared_key
# # }