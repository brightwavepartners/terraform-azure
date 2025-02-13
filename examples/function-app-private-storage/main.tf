# global naming conventions and resources
module "globals" {
  source = "../../modules/globals"

  application = local.application
  environment = local.environment
  location    = local.location
  tenant      = local.tenant
}

# utilitiies, like getting current ip address
module "utilities" {
  source = "../../modules/utilities"
}

# resource group
module "resource_group" {
  source = "../../modules/resource_group"

  application  = local.application
  contributors = []
  environment  = local.environment
  location     = local.location
  readers      = []
  tags         = {}
  tenant       = local.tenant
}

# virtual network
module "virtual_network" {
  source = "../../modules/virtual_network"

  address_space       = ["10.0.0.0/24"]
  application         = local.application
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  tags                = local.tags
  tenant              = local.tenant
}

# function app subnet
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
  virtual_network_name                = module.virtual_network.name
  virtual_network_resource_group_name = module.virtual_network.resource_group_name

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

# app service plan
module "app_service_plan" {
  source = "../../modules/service_plan"

  application                  = local.application
  environment                  = local.environment
  location                     = local.location
  maximum_elastic_worker_count = 1
  resource_group_name          = module.resource_group.name
  os_type                      = local.app_service_plan.kind
  role                         = local.app_service_plan.role
  sku_name                     = local.app_service_plan.sku
  tags                         = local.tags
  tenant                       = local.tenant
}

# function app
module "functions" {
  source = "../../modules/function_app"

  always_on         = false
  app_settings      = {}
  application       = local.application
  application_stack = local.function.application_stack
  cors_settings = {
    allowed_origins = [
      "https://functions.azure.com",
      "https://functions-next.azure.com",
      "https://functions-staging.azure.com"
    ],
    support_credentials = false
  }
  environment         = local.environment
  location            = local.location
  resource_group_name = module.resource_group.name
  role                = local.function.role
  service_plan_id     = module.app_service_plan.id
  storage = {
    alert_settings = []
    vnet_integration = {
      allowed_ips               = [module.utilities.ip]
      enabled                   = true
      file_share_retention_days = 0
    }
  }
  tags              = local.tags
  tenant            = local.tenant
  type              = local.function.type
  use_32_bit_worker = false
  vnet_integration = {
    subnet_id              = module.app_service_subnet.id
    vnet_route_all_enabled = true
  }
}
