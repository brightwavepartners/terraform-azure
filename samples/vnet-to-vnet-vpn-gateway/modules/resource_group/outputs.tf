output "location" {
    value = module.resource_group.location
}

output "name" {
    value = module.resource_group.name
}

output "virtual_network_gateway" {
    value = azurerm_virtual_network_gateway.virtual_network_gateway
}