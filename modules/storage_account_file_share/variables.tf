variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "file_share_name" {
  type        = string
  description = "The name to give to the file share."
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "maximum_size" {
  type = number
  default = 50
  description = "The maximum size of the share, in gigabytes."
}

variable "resource_group_name" {
  type        = string
}

variable "retention_days" {
  type = number
  default = 7
  description = "Defines how long to retain the file share after deletion (sof-delete)."
}

variable "role" {
  type = string
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account that the file share will be attached to."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
