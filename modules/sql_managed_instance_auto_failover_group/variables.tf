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
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "keyvault_id" {
  type        = string
  description = "The unique identifier of a Key Vault where the SQL administrator password can be pushed."
}

variable "managed_instance_properties" {
  type = object(
    {
      primary = object(
        {
          location                    = string,
          network_security_group_name = string,
          resource_group_name         = string,
          subnet_id                   = string,
          subnet_address              = string
        }
      ),
      secondary = object(
        {
          location                    = string,
          network_security_group_name = string,
          resource_group_name         = string,
          subnet_id                   = string,
          subnet_address              = string
        }
      )
    }
  )
  description = "Specifies settings for the managed instance."
}

variable "sql_properties" {
  type = object(
    {
      administrator_username       = string,
      collation                    = string,
      license_type                 = string,
      public_data_endpoint_enabled = string,
      storage_size_in_gb           = string,
      timezone_id                  = string,
      vcores                       = string
    }
  )
  description = "Specifies settings for the sql server."
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
  description = "Specifies the product type for the sql server."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
