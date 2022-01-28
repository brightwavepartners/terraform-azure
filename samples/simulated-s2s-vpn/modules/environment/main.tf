# global naming conventions and resources
module "globals" {
  source = "github.com/brightwavepartners/terraform-azure.git//modules/globals?ref=cbfc8385c0399f14830742fe5904b05de18f4ccc"

  application = var.application
  environment = var.environment
  location    = var.location
  tenant      = var.tenant
}

# resource group
module "resource_group" {
  source = "github.com/brightwavepartners/terraform-azure.git//modules/resource-group?ref=cbfc8385c0399f14830742fe5904b05de18f4ccc"

  application  = var.application
  contributors = []
  environment  = var.environment
  location     = var.location
  readers      = []
  tags         = {}
  tenant       = var.tenant
}

# virtual network
resource "azurerm_virtual_network" "virtual_network" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = module.resource_group.name
  name                = lower("${module.globals.resource_base_name_long}-${module.globals.role_names.network}-${module.globals.object_type_names.virtual_network}")
}

# virtual network gateway subnet
resource "azurerm_subnet" "virtual_network_gateway_subnet" {
  address_prefixes     = ["10.0.255.0/27"]
  name                 = "GatewaySubnet"
  resource_group_name  = module.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
}

# public ip address for the virtual network gateway
resource "azurerm_public_ip" "public_ip" {
  allocation_method   = "Dynamic"
  location            = var.location
  name                = lower("${module.globals.resource_base_name_long}-vnetgateway-ip")
  resource_group_name = module.resource_group.name
}

# virtual network gateway
resource "azurerm_virtual_network_gateway" "virtual_network_gateway" {
  location            = var.location
  name                = lower("${module.globals.resource_base_name_long}-${module.globals.role_names.network}-vng")
  resource_group_name = module.resource_group.name
  sku                 = "VpnGw2"
  type                = "Vpn"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.virtual_network_gateway_subnet.id
  }
}
