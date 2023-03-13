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

# sql servers
module "sql_servers" {
  source = "../../modules/sql_server"

  for_each = {
    for sql_server in local.sql_servers :
    lower(
      join(
        "-",
        [
          module.globals.resource_base_name_long,
          sql_server.role,
          module.globals.object_type_names.sql_server
        ]
    )) => sql_server if sql_server.enabled
  }

  administrator_login    = each.value.administrator_login
  administrator_password = each.value.administrator_password
  application            = local.application
  databases              = try(each.value.databases, [])
  elastic_pools          = try(each.value.elastic_pools, [])
  environment            = local.environment
  location               = local.location
  resource_group_name    = module.resource_group.name
  role                   = each.value.role
  sql_version            = each.value.version
  tags                   = local.tags
  tenant                 = local.tenant
}

