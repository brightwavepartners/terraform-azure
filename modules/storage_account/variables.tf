variable "account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this sotrage account."
}

variable "account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account."
}

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
  description = "Defines alert settings for the Storage Account."
}


variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "Whether or not to allow public access to all blobs or containers in the storage account."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "blob_cors_rules" {
  type = list(
    object(
      {
        allowed_headers    = list(string),
        allowed_methods    = list(string),
        allowed_origins    = list(string),
        exposed_headers    = list(string),
        max_age_in_seconds = number
      }
    )
  )
  default     = []
  description = "Settings that allow access to the blob storage content from other domains."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "allowed_ips" {
  type        = list(string)
  default     = []
  description = "List of public IP or IP ranges in CIDR format that are allowed access to the storage account."
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the app service will be created."
}

variable "role" {
  type        = string
  description = "Specifies a role for the storage account that will be used to name the account."
}

variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "The resource identifiers of the subnets that the storage account will be associated to."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
