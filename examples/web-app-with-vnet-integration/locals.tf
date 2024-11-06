locals {
  configuration = {
    apps = [
      {
        always_on                 = true
        role                      = "api"
        service_plan_role         = "apps1"
        use_32_bit_worker_process = false
      },
    ]
    application = "webapp"
    environment = "sbx"
    regions = {
      primary_region = {
        location = "northcentralus"
        virtual_network = {
          address_space = ["10.0.0.0/24"]
        }
      }
      auxiliary_regions = [
        {
          location = "centralus"
          virtual_network = {
            address_space = ["10.0.1.0/24"]
          }
        },
        {
          location = "southcentralus"
          virtual_network = {
            address_space = ["10.0.2.0/24"]
          }
        }
      ]
    }
    service_plans = [
      {
        os_type  = "Windows"
        role     = "apps1"
        sku_name = "P1v3"
        subnet = {
          netnum  = 0
          newbits = 3
        }
      }
    ]
    tags   = {}
    tenant = "gressman"
  }
}
