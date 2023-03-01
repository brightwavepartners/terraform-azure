data "azurerm_client_config" "current" {}

# global naming conventions and resources
module "globals" {
  source = "../../modules/globals"

  application = local.application
  environment = local.environment
  location    = local.location
  tenant      = local.tenant
}

# resource group
module "resource_group" {
  source = "../../modules/resource_group"

  application = local.application
  environment = local.environment
  location    = local.location
  tags        = local.tags
  tenant      = local.tenant
}

# app service plan
module "app_service_plan" {
  source = "../../modules/app_service_plan"

  application         = local.application
  environment         = local.environment
  location            = local.location
  os_type             = local.app_service_plan.os_type
  resource_group_name = module.resource_group.name
  role                = local.app_service_plan.role
  sku_name            = local.app_service_plan.sku_name
  tags                = local.tags
  tenant              = local.tenant
}

# app service
module "app_service" {
  source = "../../modules/app_service"

  app_service_plan_info = {
    id      = module.app_service_plan.id
    os_type = module.app_service_plan.os_type
  }
  application         = local.application
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = local.app_service.role
  tags                = local.tags
  tenant              = local.tenant
  vnet_integration = {
    subnet_id              = module.app_service_subnet.id
    vnet_route_all_enabled = true
  }
  webjobs_storage = {
    alert_settings = []
    vnet_integration = {
      enabled     = false
    }
  }
}



# utilitiies, like getting current ip address
module "utilities" {
  source = "../../modules/utilities"
}

# virtual network
resource "azurerm_virtual_network" "virtual_network" {
  location            = module.resource_group.location
  name                = lower("${module.globals.resource_base_name_long}-${module.globals.role_names.network}-${module.globals.object_type_names.virtual_network}")
  resource_group_name = module.resource_group.name
  address_space       = ["10.0.0.0/24"]
}

# app services subnets
module "app_service_subnet" {
  source = "../../modules/subnet"

  address_prefixes                    = ["10.0.0.0/24"]
  application                         = local.application
  environment                         = local.environment
  location                            = local.location
  name                                = lower("${local.application}-${local.app_service_plan.role}-${local.environment}")
  resource_group_name                 = module.resource_group.name
  role                                = local.app_service_plan.role
  tags                                = local.tags
  tenant                              = local.tenant
  virtual_network_name                = azurerm_virtual_network.virtual_network.name
  virtual_network_resource_group_name = azurerm_virtual_network.virtual_network.resource_group_name

  delegation = {
    name = "Microsoft.Web.serverFarms"

    service_delegation = {
      name = "Microsoft.Web/serverFarms"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }

  service_endpoints = [
    "Microsoft.Storage"
  ]
}
