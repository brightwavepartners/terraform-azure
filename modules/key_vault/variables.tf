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
  description = "Defines alert settings for the Key Vault."
}

variable "allowed_ips" {
  type        = list(string)
  default     = []
  description = "The Key Vault is integrated into a virtual network. This is the list of IP addresses that are outside the virtual network that will be allowed to access the Key Vault."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
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
  description = "Defines the configuration for diagnostics settings on the App Service Plan."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "full_access_ids" {
  type        = list(string)
  default     = []
  description = "The list of Azure Active Directory object ids that will full access to the key vault."
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The unique identifier for a Log Analytics Workspace where Key Vault diagnostics logs will be sent."
}

variable "purge_protection_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable purge protection for the key vault."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the app service will be created."
}

variable "secrets_readonly_ids" {
  type        = list(string)
  default     = []
  description = "The list of object ids that will have readonly access to the secrets."
}

variable "sku" {
  type        = string
  description = "Specifies the key vault product type."
}

variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "The list of subnet identifiers to add to the selected network list."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
