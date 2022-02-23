variable "allowed_ips" {
  type        = list(string)
  description = "The Service Bus is integrated into a virtual network. This is the list of IP addresses that are outside the virtual network that will be allowed to access the Service Bus."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "capacity" {
  type        = number
  default     = 0
  description = "Specifies capacity when the sku is Premium. Basic and Standard skus can only have a capcity of 0."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The unique identifier for a Log Analytics Workspace where Service Bus diagnostics logs will be sent."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the service bus will be created."
}

variable "sku" {
  type        = string
  description = "Specifies the service bus product type."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnet identifiers to add to the network rules."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

# we could trigger vnet integration based on whether valid subnet_ids is passed or not.
# this would typically be done using a for_each or count on the value of the subnet_id and
# simply not create the vnet integration if it is null or empty. unfortunately, in some cases
# the subnet_ids would not be known until after an apply operation so terraform would give an error
# like 'The "count" value depends on resource attributes that cannot be determined until apply'.
# to get around that issue, this flag is used to trigger vnet integration because it is a simple
# bool value that is known before apply.
variable "vnet_integration_enabled" {
  type        = bool
  description = "Determines if the App Service will be integrated into a virtual network."
}
