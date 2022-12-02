variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the app service will be created."
}

variable "retention_period" {
  type        = string
  description = "The amount of time, in days, to retain data in the workspace."
}
variable "sku" {
  type        = string
  description = "Specifies the Log Analytics Workspace product type."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
