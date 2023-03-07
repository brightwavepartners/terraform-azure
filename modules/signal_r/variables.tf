variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Specifies the number of units associated with this SignalR service."
}

variable "connectivity_logs_enabled" {
  type        = bool
  default     = false
  description = "Specifies if detailed information for SignalR hub connections is turned on."
}

variable "cors" {
  type = object(
    {
      allowed_origins = list(string)
    }
  )
  default     = null
  description = "Defines CORS settings for the SignalR instance."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the infrastructure is being provisioned."
}

variable "messaging_logs_enabled" {
  type        = bool
  default     = false
  description = "Specifies if tracing information for SignalR hub messages received and sent is turned on."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in infrastructure will be provisioned."
}

variable "service_mode" {
  type        = string
  default     = "Default"
  description = "Specifies the service mode for the SignalR instance."
}

variable "sku" {
  type        = string
  description = "Specifies the SignalR product type."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
