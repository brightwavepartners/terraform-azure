locals {
  configuration = {
    application = "frontdoor"
    apps = [
      {
        role              = "frontdoor",
        service_plan_role = "apps1"
      }
    ]
    environment = "sbx"
    front_door = {
      endpoints = [
        {
          name = "hrcenter"
          security_policy = {
            name = "securityPolicy1"
            web_application_firewall_policy = {
              mode     = "Prevention"
              name     = "wafPolicy1"
              sku_name = "Standard_AzureFrontDoor"
            }
          }
          routes = [
            {
              name = "default"
              origin_group = {
                health_probe = {
                  internal_in_seconds = 100
                  path                = "/"
                  protocol            = "Http"
                  request_type        = "HEAD"
                }
                load_balancing = {
                  additional_latency_in_milliseconds = 0
                  sample_size                        = 16
                  successful_samples_required        = 3
                }
                name = "default"
                origins = [
                  {
                    certificate_name_check_enabled = true
                    host_name                      = "${join(
                      "-",
                      [
                        local.configuration.tenant,
                        local.configuration.application,
                        local.configuration.environment,
                        "ncus",
                        local.configuration.apps[0].role,
                        "as"
                      ]
                    )}.azurewebsites.net"
                    name      = "origin1"
                  }
                ]
              }
              patterns_to_match   = ["/"]
              supported_protocols = ["Http", "Https"]
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
        os_type  = "Windows"
        role     = "apps1"
        sku_name = "F1"
      }
    ]
    tags   = {}
    tenant = var.tenant
  }
}
