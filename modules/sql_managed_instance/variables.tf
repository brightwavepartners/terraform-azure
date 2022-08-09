variable "allow_public_access" {
  type        = bool
  description = "Determines whether or not to enable public access to the managed instance."
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
  description = "Defines the configuration for diagnostics settings on the Service Bus."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)."
}

variable "keyvault_id" {
  type        = string
  description = "The unique identifier of a Key Vault where the SQL administrator password can be pushed."
}

variable "location" {
  type        = string
  description = "The Azure region where the managed instance will be deployed."
}

variable "properties" {
  type = object(
    {
      administrator_username       = string,
      collation                    = string,
      dns_zone_partner             = string,
      license_type                 = string,
      public_data_endpoint_enabled = bool,
      storage_size_in_gb           = number,
      timezone_id                  = string,
      vcores                       = number
    }
  )
  description = "Specifies various settings for the managed instance."
}

variable "network_security_group_name" {
  type        = string
  description = "The name of the network security group that rules will be added to."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the managed instance will be created."
}

variable "sku" {
  type = object(
    {
      capacity : number,
      family : string,
      name : string,
      tier : string
    }
  )
  description = "Specifies the product type for the managed instance."
}

variable "subnet_address" {
  type        = string
  description = "The address of the subnet in which the managed instance will be provisioned."
}

variable "subnet_id" {
  type        = string
  description = "The Azure resource identifier of the subnet in which the managed instance will be provisioned."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
