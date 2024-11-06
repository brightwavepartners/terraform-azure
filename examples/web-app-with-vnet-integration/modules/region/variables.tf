variable "configuration" {
  type        = any
  description = "Configuration values that define how to provision resources."
}

variable "location" {
  type        = string
  description = "The region in which to provision the resources."
}

variable "virtual_network_address_space" {
  type        = list(string)
  description = "The address space(s) to provision for the region's virtual network."
}

