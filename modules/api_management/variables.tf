variable "additional_locations" {
  type = list(
    object(
      {
        location  = string
        subnet_id = string
      }
    )
  )
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "A list of availability zones."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the app service will be deployed."
}

variable "publisher_email" {
  type        = string
  description = "The email of the publisher/company."
}

variable "publisher_name" {
  type        = string
  description = "The name of the publisher/company."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the API Management will be created."
}

variable "sku" {
  type        = string
  description = "A string indicating which product to provision, consisting of two parts separated by an underscore(_). The first part is the name (e.g. Premium). The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Premium_1)."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "If virtual network integration is enabled (via virtual_network_type variable), this is the Azure resource identifier for the subnet that API Management will be proviseiond in."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "virtual_network_type" {
  type        = string
  description = "The type of virtual network applied to the API Management instance."
}
