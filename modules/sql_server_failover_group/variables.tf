variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "read_write_endpoint_failover_policy" {
  type = object(
    {
      mode = string
      grace_minutes = optional(number)
    }
  )
  default = {
    mode = "Automatic"
    grace_minutes = 90
  }
  description = "Defines the failover settings to apply to the read-write server."
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "The unique Azure identifier for a key vault that will be used to store an automatically generated admin password for the SQL Server."
}

variable "servers" {
  type = object(
    {
      primary_server = object(
        {
          administrator_login    = string
          administrator_password = optional(string)
          allowed_subnets = optional(
            list(
              object(
                {
                  name = string
                  id   = string
                }
              )
            )
          )
          azure_ad_administrator = optional(
            object(
              {
                name      = string
                object_id = string
              }
            )
          )
          databases = optional(
            list(
              object(
                {
                  name = optional(string)
                  role = string
                }
              )
            )
          )
          elastic_pools = optional(
            list(
              object(
                {
                  databases = optional(
                    list(
                      object(
                        {
                          name = optional(string)
                          role = string
                        }
                      )
                    )
                  )
                  license_type   = optional(string) # if a value is not provided here, it will end up being null when used and the Azure default is "LisenceIncluded"
                  max_size_bytes = optional(number) # one (and only one) of max_size_gb or max_size_bytes needs to be specified
                  max_size_gb    = optional(number) # one (and only one) of max_size_gb or max_size_bytes needs to be specified
                  name           = optional(string)
                  per_database_settings = object(
                    {
                      max_capacity = number
                      min_capacity = number
                    }
                  )
                  role = string
                  sku = object(
                    {
                      name     = string
                      capacity = number
                      tier     = string
                      family   = optional(string)
                    }
                  )
                }
              )
            ),
            []
          )
          firewall_rules = optional(
            list(
              object(
                {
                  end_ip_address   = string
                  name             = string
                  start_ip_address = string
                }
              )
            ),
            []
          )
          key_vault_id        = optional(string)
          location            = string
          name                = optional(string)
          resource_group_name = string
          role                = string
          version             = string
          subnets = optional(
            list(
              object(
                {
                  name = string
                  id   = string
                }
              )
            ),
            []
          )
          version = string
        }
      )
      secondary_server = object(
        {
          administrator_login    = string
          administrator_password = optional(string)
          allowed_subnets = optional(
            list(
              object(
                {
                  name = string
                  id   = string
                }
              )
            )
          )
          azure_ad_administrator = optional(
            object(
              {
                name      = string
                object_id = string
              }
            )
          )
          databases = optional(
            list(
              object(
                {
                  name = optional(string)
                  role = string
                }
              )
            )
          )
          elastic_pools = optional(
            list(
              object(
                {
                  databases = optional(
                    list(
                      object(
                        {
                          name = optional(string)
                          role = string
                        }
                      )
                    )
                  )
                  license_type   = optional(string) # if a value is not provided here, it will end up being null when used and the Azure default is "LisenceIncluded"
                  max_size_bytes = optional(number) # one (and only one) of max_size_gb or max_size_bytes needs to be specified
                  max_size_gb    = optional(number) # one (and only one) of max_size_gb or max_size_bytes needs to be specified
                  name           = optional(string)
                  per_database_settings = object(
                    {
                      max_capacity = number
                      min_capacity = number
                    }
                  )
                  role = string
                  sku = object(
                    {
                      name     = string
                      capacity = number
                      tier     = string
                      family   = optional(string)
                    }
                  )
                }
              )
            ),
            []
          )
          firewall_rules = optional(
            list(
              object(
                {
                  end_ip_address   = string
                  name             = string
                  start_ip_address = string
                }
              )
            ),
            []
          )
          key_vault_id        = optional(string)
          location            = string
          name                = optional(string)
          resource_group_name = string
          role                = string
          version             = string
          subnets = optional(
            list(
              object(
                {
                  name = string
                  id   = string
                }
              )
            ),
            []
          )
          version = string
        }
      )
    }
  )
  description = "Defines settings for each of the servers in the failover group."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
