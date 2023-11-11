variable "application" {}

variable "environment" {}

variable "configuration" {
  type        = any
  description = "Configuration values that define how to provision resources."
}

variable "location" {
  type        = string
  description = "The region in which to provision the resources."
}

variable "tags" {}

variable "tenant" {}