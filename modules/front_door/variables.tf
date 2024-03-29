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
                  health_probe = optional(
                    object(
                      {
                        internal_in_seconds = number
                        path                = optional(string)
                        protocol            = string
                        request_type        = optional(string)
                      }
                    )
                  )
                  load_balancing = object(
                    {
                      additional_latency_in_milliseconds = optional(number)
                      sample_size                        = optional(number)
                      successful_samples_required        = optional(number)
                    }
                  )
                  name = string
                  origins = list(
                    object(
                      {
                        certificate_name_check_enabled = bool
                        host_name                      = string
                        name                           = string
                      }
                    )
                  )
                }
              )
              patterns_to_match   = list(string)
              supported_protocols = list(string)
            }
          )
        )
        security_policy = optional(
          object(
            {
              name = string
              web_application_firewall_policy = object(
                {
                  mode     = string
                  name     = string
                  sku_name = string
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
