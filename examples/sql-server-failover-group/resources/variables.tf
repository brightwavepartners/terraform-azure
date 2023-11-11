variable "application" {}

variable "configuration" {
  type        = any
  description = "Configuration values that define how to provision resources."
}

variable "environment" {}

variable "location" {
  type        = string
  description = "The region in which to provision the resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to provision resources."
}

variable "tags" {}

variable "tenant" {}

variable "virtual_network_address_space" {
  type = list(string)
  description = "The address space(s) to provision for the region's virtual network."
}

