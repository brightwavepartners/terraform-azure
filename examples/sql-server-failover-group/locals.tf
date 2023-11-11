locals {
  application = "sqlfailover"
  configuration = {
    key_vault = {
      purge_protection_enabled = false
      sku                      = "standard"
    }
    regions = {
      primary_region = {
        location = "northcentralus",
        virtual_network = {
          address_space = ["10.0.0.0/24"]
        }
      },
      auxiliary_regions = [
        {
          location = "southcentralus",
          virtual_network = {
            address_space = ["10.0.1.0/24"]
          }
        }
      ]
    }
    sql_failover_groups = [
      {
        primary_server = {
          administrator_login = "sandboxadmin"
          databases = [
            {
              role = "admin"
            }
          ]
          location    = "northcentralus"
          role        = "admin"
          version = "12.0"
          subnets = []
        }
        secondary_server = {
          administrator_login = "sandboxadmin"
          databases = [
            {
              role = "admin"
            }
          ]
          location    = "southcentralus"
          role        = "admin"
          version = "12.0"
          subnets = []
        }
      }
    ]
  }
  environment = "sbx"
  primary_region_resource_group = try(
    element(
      [
        for resource_groups in module.resource_groups : resource_groups.resource_group
        if resource_groups.resource_group.location == local.configuration.regions.primary_region.location
      ],
      0
    ),
    null
  )
  tags   = {}
  tenant = var.tenant
}
