variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "databases" {
  type = list(
    object(
      {
        name = optional(string)
        role = string
      }
    )
  )
  default     = []
  description = "Databases that will be provisioned and attached to this elastic pool."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "license_type" {
  type        = string
  default     = null
  description = "The license type applied to the elastic pool. If a value is not provided here, it will end up being null when used and the Azure default is 'LisenceIncluded'"
}

variable "location" {
  type        = string
  description = "The Azure region where the infrastructure is being provisioned."
}

variable "max_size_bytes" {
  type        = number
  default     = null
  description = "The max size fo the elastic pool in bytes. Conflicts with max_size_gb."
}

variable "max_size_gb" {
  type        = number
  default     = null
  description = "The max size fo the elastic pool in gigabytes. Conflicts with max_size_bytes."
}

variable "name" {
  type        = string
  default     = null
  description = "The name to give to the SQL database. If no name is provided, a default name will be used based on the global azure naming convention of this library."
}

variable "per_database_settings" {
  type = object(
    {
      max_capacity = number
      min_capacity = number
    }
  )
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in infrastructure will be provisioned."
}

variable "role" {
  type        = string
  description = "Defines a role name for the elastic pool that is used to name the resource."
}

variable "sku" {
  type = object(
    {
      capacity = number
      family   = optional(string)
      name     = string
      tier     = string
    }
  )
  description = "Defines the product sku details used to provision the elastic pool."
}

variable "sql_server" {
  type = object(
    {
      id   = string
      name = string
    }
  )
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
