# setup the two azure envrionments that will be connected via vpn
# module "environments" {
#   source = "./modules/environment"

#   for_each = local.environments

#   application = local.application
#   environment = each.value
#   location    = local.location
#   tenant      = local.tenant
# }

# connect the two environments
resource "azurerm_virtual_network_gateway_connection" "azure_to_onprem" {
  name                = "${keys(local.environments[0])}-to-${keys(local.environments[1])}"
  location            = module.environments[0].location
  resource_group_name = module.environments[0].name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.us.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.europe.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}