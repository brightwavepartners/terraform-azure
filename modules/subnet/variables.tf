variable "address_prefixes" {}

variable "application" {
  type        = string
  description = "The name of the application the infrastructure is being provisioned for."
}

variable "delegation" {
  type = object(
    {
      name = string,
      service_delegation = object(
        {
          name    = string,
          actions = list(string)
        }
      )
    }
  )
  default = null
}

variable "environment" {}

variable "location" {
  type        = string
  description = "The region in which to provision the resources."
}

variable "name" {}

variable "network_security_group_rules" {
  type = list(
    object(
      {
        access                                     = string
        description                                = string
        destination_address_prefix                 = string
        destination_address_prefixes               = optional(list(string))
        destination_application_security_group_ids = optional(list(string))
        destination_port_range                     = optional(string)
        destination_port_ranges                    = optional(list(string))
        direction                                  = string
        name                                       = string
        priority                                   = number
        protocol                                   = string
        source_address_prefix                      = string
        source_address_prefixes                    = optional(list(string))
        source_application_security_group_ids      = optional(list(string))
        source_port_range                          = optional(string)
        source_port_ranges                         = optional(list(string))
      }
    )
  )
  default     = []
  description = "Defines the security rules that will be added to the network security group associated with the subnet."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the network security group will be provisioned."
}

variable "role" {
  type        = string
  description = "Defines the role that the subnet plays and is used in naming the subnet and associated network security group."
}

variable "service_endpoints" {
  type    = list(string)
  default = null
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "The name of the organization that the infrastructure is being provisioned for."
}

variable "virtual_network_name" {}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "The name of the resource group in which the virtual network is provisioned."
}
