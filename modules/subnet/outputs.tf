output "address_prefixes" {
  value = azurerm_subnet.subnet.address_prefixes
}

output "id" {
  value = azurerm_subnet.subnet.id
}

output "name" {
  value = azurerm_subnet.subnet.name
}

output "network_security_group_id" {
  value = azurerm_network_security_group.network_security_group[0].id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.network_security_group[0].name
}