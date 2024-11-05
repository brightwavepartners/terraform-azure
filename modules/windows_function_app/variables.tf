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
  description = "Defines alert settings for the Function App."
}

variable "always_on" {
  type        = bool
  default     = false
  description = "Should the Function App stay loaded all the time?"
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Global configuration options that affect all functions for the function app. These are the Application settings found under the Configuration menu of the Function App."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "application_stack" {
  type = object(
    {
      dotnet_version              = optional(string)
      use_dotnet_isolated_runtime = optional(bool)
    }
  )
  description = "Defines the application stack that the function app will run on."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "cors_settings" {
  type = object(
    {
      allowed_origins     = list(string),
      support_credentials = bool
    }
  )
  default = {
    allowed_origins     = []
    support_credentials = false
  }
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
                retention = optional(
                  object(
                    {
                      days    = number
                      enabled = bool
                    }
                  )
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
                retention = optional(
                  object(
                    {
                      days    = number
                      enabled = bool
                    }
                  )
                )
              }
            )
          )
        )
      }
    )
  )
  default     = []
  description = "Defines the configuration for diagnostics settings on the Function App"
}

variable "ip_restrictions" {
  type = list(
    object(
      {
        action      = optional(string)
        description = string
        headers = optional(
          list(
            object(
              {
                front_door_ids          = list(string)
                front_door_health_probe = list(string)
                forwarded_for           = list(string)
                forwarded_host          = list(string)
              }
            )
          )
        )
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
      }
    )
  )
  default     = []
  description = "A list of ip restrictions for inbound access to the Function App."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The Azure resource identifier for a Log Analytics Workspace that Application Insight instances will be attached to."
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "minimum_instance_count" {
  type        = number
  default     = 1
  description = "The minimum number of instances. Only affects apps on the Premium plan."
}

variable "name" {
  type        = string
  default     = null
  description = "The name given to the function app. Value only required if you want to override the default name that will be provided if this value is null."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Function App will be created."
}

variable "role" {
  type        = string
  description = "Defines a role name for the Function App so it can be referred to by this name when attaching to an App Service Plan."
}

variable "service_plan_id" {
  type        = string
  description = "The unique identifier for the App Service Plan to which the Function App will be attached."
}

variable "storage" {
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
      maximum_size = optional(number)
      vnet_integration = object(
        {
          allowed_ips               = optional(list(string))
          enabled                   = bool
          file_share_retention_days = optional(number)
        }
      )
    }
  )
  default     = null
  description = "Determines how to configure the storage account backing the Function App."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "use_32_bit_worker" {
  type        = bool
  default     = true
  description = "If the Function App should run in 32 bit mode, rather than 64 bit mode."
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
