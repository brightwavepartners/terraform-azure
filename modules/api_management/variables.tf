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
  description = "Defines alert settings for the API Management instance."
}

variable "additional_locations" {
  type = list(
    object(
      {
        location  = string
        subnet_id = string
      }
    )
  )
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "application_insights" {
  type = object(
    {
      always_log_errors         = bool
      http_correlation_protocol = string
      loganalytics_workspace_id = string
      log_client_ip_address     = bool
      sampling_rate_percentage  = number
      verbosity                 = string
      backend_request = optional(
        object(
          {
            headers_to_log       = list(string)
            payload_bytes_to_log = number
          }
        )
      )
      backend_response = optional(
        object(
          {
            headers_to_log       = list(string)
            payload_bytes_to_log = number
          }
        )
      )
      frontend_request = optional(
        object(
          {
            headers_to_log       = list(string)
            payload_bytes_to_log = number
          }
        )
      )
      frontend_response = optional(
        object(
          {
            headers_to_log       = list(string)
            payload_bytes_to_log = number
          }
        )
      )
    }
  )
  default     = null
  description = "Defines how to configure an Application Insights instance to connect to API(s) in the API Management instance."
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "A list of availability zones."
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
  description = "Defines the configuration for diagnostics settings on the API Management instance."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the app service will be deployed."
}

variable "publisher_email" {
  type        = string
  description = "The email of the publisher/company."
}

variable "publisher_name" {
  type        = string
  description = "The name of the publisher/company."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the API Management will be created."
}

variable "sku" {
  type        = string
  description = "A string indicating which product to provision, consisting of two parts separated by an underscore(_). The first part is the name (e.g. Premium). The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Premium_1)."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "If virtual network integration is enabled (via virtual_network_type variable), this is the Azure resource identifier for the subnet that API Management will be proviseiond in."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "virtual_network_type" {
  type        = string
  description = "The type of virtual network applied to the API Management instance."
}
