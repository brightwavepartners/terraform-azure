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
  description = "Defines alert settings for the Service Bus."
}

variable "allowed_ips" {
  type        = list(string)
  description = "The Service Bus is integrated into a virtual network. This is the list of IP addresses that are outside the virtual network that will be allowed to access the Service Bus."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "capacity" {
  type        = number
  default     = 0
  description = "Specifies capacity when the sku is Premium. Basic and Standard skus can only have a capcity of 0."
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
  description = "Defines the configuration for diagnostics settings on the Service Bus."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "queues" {
  type = list(
    object(
      {
        enable_batched_operations = bool,
        name                      = string
      }
    )
  )
  default     = []
  description = "The list of queues to create on the Service Bus."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the service bus will be created."
}

variable "sku" {
  type        = string
  description = "Specifies the service bus product type."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnet identifiers to add to the network rules."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "topics" {
  type = list(
    object(
      {
        enable_batched_operations = bool,
        name                      = string,
        policies = list(
          object(
            {
              name = string,
              claims = object(
                {
                  listen = bool,
                  manage = bool,
                  send   = bool
                }
              )
            }
          )
        ),
        support_ordering = bool
      }
    )
  )
  default     = []
  description = "The list of topics to create on the Service Bus."
}

# we could trigger vnet integration based on whether valid subnet_ids is passed or not.
# this would typically be done using a for_each or count on the value of the subnet_id and
# simply not create the vnet integration if it is null or empty. unfortunately, in some cases
# the subnet_ids would not be known until after an apply operation so terraform would give an error
# like 'The "count" value depends on resource attributes that cannot be determined until apply'.
# to get around that issue, this flag is used to trigger vnet integration because it is a simple
# bool value that is known before apply.
variable "vnet_integration_enabled" {
  type        = bool
  description = "Determines if the App Service will be integrated into a virtual network."
}
