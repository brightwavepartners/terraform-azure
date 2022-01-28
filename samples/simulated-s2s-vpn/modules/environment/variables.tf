variable "application" {}

variable "environment" {
  type        = string
  default     = null
  description = "An environment identifier used to differentiate different vpn targets."
}

variable "location" {}

variable "tenant" {}