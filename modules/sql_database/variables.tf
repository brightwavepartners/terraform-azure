variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "collation" {
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  description = "The collation for the database."
}

variable "elastic_pool" {
  type        = string
  default     = null
  description = <<EOF
        The unique Azure identifier for an elastic pool that this database will be attached to.
        If no elastic pool identifier is provided, the database will not be attached to an
        elastic pool and will be just a stand-alone database.
    EOF
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "license_type" {
  type        = string
  default     = null
  description = "The license type applied to the database. If a value is not provided here, it will end up being null when used and the Azure default is 'LisenceIncluded'"
}

variable "location" {
  type        = string
  description = "The Azure region where the infrastructure is being provisioned."
}

variable "name" {
  type        = string
  default     = null
  description = "The name to give to the SQL database. If no name is provided, a default name will be used based on the global azure naming convention of this library."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in infrastructure will be provisioned."
}

variable "role" {
  type        = string
  description = "Defines a role name for the SQL database that is used to name the resource."
}

variable "sql_server" {
  type        = string
  description = "The unique Azure identifier for the SQL server that this database should be attached to."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
