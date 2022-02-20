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
