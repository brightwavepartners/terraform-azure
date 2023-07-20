variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "endpoints" {
  type = list(
    object(
      {
        name = string
        routes = list(
          object(
            {
              name = string
              origin_group = object(
                {
                  name = string
                }
              )
            }
          )
        )
      }
    )
  )
  default     = []
  description = <<EOF
    Defines the logical groupings of one or more routes that are associated with domain names.
    Each endpoint is assigned a domain name.
  EOF
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "location" {
  type        = string
  description = "The Azure region where the front door will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Front Door will be created."
}

variable "sku_name" {
  type        = string
  description = "Specifies the front door product type."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}
