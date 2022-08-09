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
  description = "Defines alert settings for the CDN."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "content_types_to_compress" {
  type        = list(string)
  default     = []
  description = "An array of strings that indicates which content types will have compression applied."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "http_allowed" {
  type        = bool
  default     = true
  description = "Whether or not HTTP traffic should be allowed through the CDN."
}

variable "https_allowed" {
  type        = bool
  default     = true
  description = "Whether or not HTTPS traffic should be allowed through the CDN."
}

variable "location" {
  type        = string
  description = "The Azure region where the app service will be deployed."
}

variable "origin_group_name" {
  type        = string
  description = "The name of the origin group in which origins will be contained."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which resources will be provisioned."
}

variable "profile_sku" {
  type        = string
  description = "The pricing related information for the CDN profile."
}

variable "storage_accounts" {
  type        = list(object({ name = string, primary_blob_host = string }))
  description = "Specifies details about the storage accounts used as the source of the endpoints."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "The name of the tenant resources are being provisioned for."
}