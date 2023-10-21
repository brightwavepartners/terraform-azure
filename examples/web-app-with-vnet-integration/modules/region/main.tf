# global naming conventions and resources
module "globals" {
  source = "../../../../modules/globals"

  application = var.configuration.application
  environment = var.configuration.environment
  location    = var.location
  tenant      = var.configuration.tenant
}

# resource group
module "resource_group" {
  source = "../../../../modules/resource_group"

  application  = var.configuration.application
  contributors = []
  environment  = var.configuration.environment
  location     = var.location
  readers      = []
  tags         = var.configuration.tags
  tenant       = var.configuration.tenant
}

# virtual network
module "virtual_network" {
  source = "../../../../modules/virtual_network"

  address_space       = var.virtual_network_address_space
  application         = var.configuration.application
  environment         = var.configuration.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.configuration.tags
  tenant              = var.configuration.tenant
}

# service plans
module "service_plans" {
  source = "../../../../modules/service_plan"

  for_each = {
    for service_plan in var.configuration.service_plans :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          service_plan.role,
          module.globals.object_type_names.app_service_plan
        ]
      )
    ) => service_plan
  }

  application         = var.configuration.application
  environment         = var.configuration.environment
  location            = var.location
  os_type             = each.value.os_type
  resource_group_name = module.resource_group.name
  role                = each.value.role
  sku_name            = each.value.sku_name
  tags                = var.configuration.tags
  tenant              = var.configuration.tenant
}

# app services subnets
module "service_plan_subnets" {
  source = "../../../../modules/subnet"

  for_each = {
    for service_plan in var.configuration.service_plans :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          service_plan.role,
          module.globals.object_type_names.subnet
        ]
      )
    ) => service_plan
  }

  address_prefixes = [
    cidrsubnet(
      var.virtual_network_address_space[0],
      each.value.subnet.newbits,
      each.value.subnet.netnum
    )
  ]
  application = var.configuration.application
  environment = var.configuration.environment
  location    = var.location
  name = lower(
    join(
      "-",
      [
        var.configuration.application,
        each.value.role,
        var.configuration.environment
      ]
    )
  )
  network_security_group_rules        = try(each.value.subnet.security_rules, [])
  resource_group_name                 = module.resource_group.name
  role                                = each.value.role
  tags                                = var.configuration.tags
  tenant                              = var.configuration.tenant
  virtual_network_name                = module.virtual_network.name
  virtual_network_resource_group_name = module.resource_group.name

  delegation = {
    name = "Microsoft.Web.serverFarms"

    service_delegation = {
      name = "Microsoft.Web/serverFarms"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }

  service_endpoints = []
}

# apps
module "apps" {
  source = "../../../../modules/windows_web_app"

  for_each = {
    for app in var.configuration.apps :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          app.role,
          module.globals.object_type_names.app_service
        ]
      )
    ) => app
  }

  application         = var.configuration.application
  environment         = var.configuration.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  role                = each.value.role

  service_plan_info = {
    id = element(
      [
        for service_plan in module.service_plans : service_plan.id
        if can(
          regex(
            lower(
              each.value.service_plan_role
            ),
            service_plan.name
          )
        )
      ], 0
    )
    os_type = element(
      [
        for service_plan in module.service_plans : service_plan.os_type
        if can(
          regex(
            lower(
              each.value.service_plan_role
            ),
            service_plan.name
          )
        )
      ], 0
    )
  }

  tags                      = var.configuration.tags
  tenant                    = var.configuration.tenant
  use_32_bit_worker_process = each.value.use_32_bit_worker_process

  vnet_integration = {
    subnet_id = element(
      [
        for service_plan_subnet in module.service_plan_subnets : service_plan_subnet.id
        if can(
          regex(
            lower(
            each.value.service_plan_role),
            service_plan_subnet.name
          )
        )
      ],
      0
    ),
    vnet_route_all_enabled = true
  }
}
