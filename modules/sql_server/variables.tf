variable "administrator_login" {
  type        = string
  description = "The login name for an administrator account (the typical SA account) that will be created when the server is provisioned."
  sensitive   = true
}

variable "administrator_password" {
  type        = string
  default     = null
  description = <<EOF
        If a password is provided, it will be used and stored in the state file. For security reasons, you can omit
        the password and one will be automatically generated. If you omit the password in favor of an automatically
        generated one, you also need to provide a key vault identifier so the automatically generated value can
        be stored in a key vault.
    EOF
  sensitive   = true
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "azure_ad_administrator" {
  type = object(
    {
      name      = string
      object_id = string
    }
  )
  default     = null
  description = "The Azure Active Directory user or group that will be added to the server as an administrator."
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
  description = "Stand-alone databases (not within an elastic pool) that will be provisioned and attached to this SQL server."
}

variable "elastic_pools" {
  type = list(
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
  )
  default = []
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "key_vault" {
  type = string
  default = null
  description = <<EOF
    The unique Azure identifier for a key vault that will be used to store an automatically generated
    admin password for the SQL Server. This method is an alternative to providing a hard-coded
    pasword and results in better security since the password is not part of the source code. If
    a key vault is provided, a password for the SQL Server admin account will be automatically
    generated and entered into the key vault provided. If no key vault is provided, a password
    must be provided.
  EOF
}

variable "location" {
  type        = string
  description = "The Azure region where the infrastructure is being provisioned."
}

variable "name" {
  type        = string
  default     = null
  description = "The name to give to the SQL server. If no name is provided, a default name will be used based on the global azure naming convention of this library."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in infrastructure will be provisioned."
}

variable "role" {
  type        = string
  description = "Defines a role name for the SQL Server that is used to name the resource."
}

variable "sql_version" {
  type        = string
  description = "The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
