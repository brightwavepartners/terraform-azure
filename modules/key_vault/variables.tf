variable "allowed_ips" {
  type        = list(string)
  default     = []
  description = "The Key Vault is integrated into a virtual network. This is the list of IP addresses that are outside the virtual network that will be allowed to access the Key Vault."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "full_access_ids" {
  type        = list(string)
  default     = []
  description = "The list of Azure Active Directory object ids that will full access to the key vault."
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The unique identifier for a Log Analytics Workspace where Key Vault diagnostics logs will be sent."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the app service will be created."
}

variable "secrets_readonly_ids" {
  type        = list(string)
  default     = []
  description = "The list of object ids that will have readonly access to the secrets."
}

variable "sku" {
  type        = string
  description = "Specifies the key vault product type."
}

variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "The list of subnet identifiers to add to the selected network list."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
