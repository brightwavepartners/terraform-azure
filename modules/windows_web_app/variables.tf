variable "alert_settings" {
  type = list(
    object(
      {
        action = object(
          {
            action_group_id = string
          }
        )
        description = string
        dynamic_criteria = optional(
          object(
            {
              aggregation              = string
              alert_sensitivity        = string
              evaluation_failure_count = optional(number)
              evaluation_total_count   = optional(number)
              metric_name              = string
              operator                 = string
            }
          )
        )
        enabled   = bool
        frequency = optional(string)
        name      = string
        severity  = number
        static_criteria = optional(
          object(
            {
              aggregation = string
              metric_name = string
              operator    = string
              threshold   = number
            }
          )
        )
        window_size = optional(string)
      }
    )
  )
  default     = []
  description = "Defines alert settings for the App Service."
}

variable "always_on" {
  type        = bool
  default     = false
  description = "Should the App Service stay loaded all the time?"
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Global configuration options for the App Service. These are the Application settings found under the Configuration menu of the App Service."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "application_stack" {
  type = object(
    {
      current_stack  = optional(string)
      dotnet_version = optional(string)
    }
  )
  default = {
    current_stack  = "dotnet"
    dotnet_version = "v6.0"
  }
  description = "Defines application stack configuration such as the runtime (e.g. dotnet) and dotnet version (e.g. v6.0)"
}

variable "application_insights" {
  type = object(
    {
      enabled                        = bool
      integrate_with_app_diagnostics = bool
      workspace_id                   = string
    }
  )
  default = {
    enabled                        = false
    integrate_with_app_diagnostics = false
    workspace_id                   = ""
  }
  description = "Determines if Application Insights will be enabled for the App Service and if so, how it should be configured."
}

variable "cors_settings" {
  type = object(
    {
      allowed_origins     = list(string)
      support_credentials = bool
    }
  )
  default      = null
  description = "Defines settings for origins that should be able to make cross-origin calls."
}

variable "diagnostics_settings" {
  type = list(
    object(
      {
        name = string
        destination = object(
          {
            log_analytics_workspace = optional(
              object(
                {
                  destination_type = optional(string)
                  id               = string
                }
              )
            )
          }
        )
        logs = optional(
          list(
            object(
              {
                category = string
                enabled  = bool
                retention = object(
                  {
                    days    = number
                    enabled = bool
                  }
                )
              }
            )
          )
        )
        metrics = optional(
          list(
            object(
              {
                category = string
                enabled  = bool
                retention = object(
                  {
                    days    = number
                    enabled = bool
                  }
                )
              }
            )
          )
        )
      }
    )
  )
  default     = []
  description = "Defines the configuration for diagnostics settings on the App Service"
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "ip_restrictions" {
  type = list(
    object(
      {
        action      = optional(string)
        description = string
        headers = optional(list(
          object(
            {
              front_door_ids          = list(string)
              front_door_health_probe = list(string)
              forwarded_for           = list(string)
              forwarded_host          = list(string)
            }
          )
        ))
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
      }
    )
  )
  default     = []
  description = "A list of ip restrictions for inbound access to the App Service."
}

variable "location" {
  type        = string
  description = "The Azure region where the app service will be deployed."
}

variable "name" {
  type        = string
  default     = null
  description = "The name to give to the App Service. If no name is provided, a default name will be used based on the global azure naming convention of this library."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the app service will be created."
}

variable "role" {
  type        = string
  description = "Defines a role name for the App Service Plan so it can be referred to by this name when attaching to an App Service Plan."
}

variable "service_plan_info" {
  type = object(
    {
      id      = string
      os_type = string # Windows or Linux
    }
  )
  description = "Information about the Service Plan that will host the Service."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "use_32_bit_worker_process" {
  type        = bool
  default     = true
  description = "If the App Service should run in 32 bit mode, rather than 64 bit mode."
}

variable "vnet_integration" {
  type = object(
    {
      subnet_id              = string
      vnet_route_all_enabled = bool
    }
  )
  default     = null
  description = "Describes how to apply virtual network integration to the Function App and its components."
}

variable "webjobs_storage" {
  type = object(
    {
      alert_settings = list(object({
        action = object(
          {
            action_group_id = string
          }
        )
        description = string
        dynamic_criteria = optional(
          object(
            {
              aggregation              = string
              alert_sensitivity        = string
              evaluation_failure_count = optional(number)
              evaluation_total_count   = optional(number)
              metric_name              = string
              operator                 = string
            }
          )
        )
        enabled   = bool
        frequency = optional(string)
        name      = string
        severity  = number
        static_criteria = optional(
          object(
            {
              aggregation = string
              metric_name = string
              operator    = string
              threshold   = number
            }
          )
        )
        window_size = optional(string)
        }
      )),
      vnet_integration = object(
        {
          allowed_ips = optional(list(string))
          enabled     = bool
        }
      )
    }
  )
  default     = null
  description = "Determines how to configure a storage account for webjobs."
}