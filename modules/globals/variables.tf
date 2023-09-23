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
  default     = null
  description = "The region in which to provision the infrastructure."
}

variable "tenant" {
  type        = string
  default     = null
  description = "Tenant name."
}
