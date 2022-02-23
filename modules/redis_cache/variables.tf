variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "family" {
  type        = string
  description = "The SKU family/pricing group to use."
}

variable "capacity" {
  type        = number
  description = "The size of the Redis Cache to deploy."
}

variable "location" {
  type        = string
  description = "The Azure region where the Redis Cache will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Redis Cache will be created."
}

variable "sku_name" {
  type        = string
  description = "The SKU of the Redis Cache."
}

variable "subnet_id" {
  type        = string
  description = "The resource identifier for the subnet in which the Redis Cache will be deployed."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
