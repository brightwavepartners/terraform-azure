locals {
  configuration = {
    application = "frontdoor"
    apps = [
      {
        role                      = "frontdoor",
        service_plan_role         = "apps1"
      }
    ]    
    environment = "sbx"
    front_door = {
      endpoints = [
        {
          name = "hrcenter"
          routes = [
            {
              name = "default"
              origin_group = {
                name = "default"
              }
            }
          ]
        }
      ]
      sku = "Standard_AzureFrontDoor"
    }
    regions = {
      primary_region = {
        location = "northcentralus"
      },
      auxiliary_regions = [
        {
          location = "southcentralus"
        }       
      ]
    }    
    service_plans = [
      {
        os_type = "Windows"
        role    = "apps1"
        sku_name = "F1"
      }
    ]
    tags   = {}
    tenant = var.tenant
  }
}
