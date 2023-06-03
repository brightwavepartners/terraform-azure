variable "address_space" {
  type        = list(string)
  description = "The list of address spaces used by the virtual network."
}

variable "application" {
  type        = string
  description = "The name of the application the infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment (e.g. dev, test, prod) for which resources are being provisioned."
}

variable "location" {
  type        = string
  description = "The region in which to provision the resources."
}

variable "name" {
  type        = string
  description = "If name is provided, the auto-generation of name will be overridden and the provided name will be used instead."
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the network security group will be provisioned."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "The name of the organization that the infrastructure is being provisioned for."
}