variable "always_on" {
  type        = bool
  description = "Should the Function App stay loaded all the time?"
}

variable "app_service_plan_id" {
  type        = string
  description = "The unique identifier for the App Service Plan to which the Function App will be attached."
}

variable "app_settings" {
  type        = map(string)
  description = "Global configuration options that affect all functions for the function app. These are the Application settings found under the Configuration menu of the Function App."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "cors_settings" {
  type = object(
    {
      allowed_origins     = list(string),
      support_credentials = bool
    }
  )
  description = "Defines settings for origins that should be able to make cross-origin calls."
}

variable "dotnet_framework_version" {
  type = string
  default = "v4.0"
  description = "The version of the .net framework's CLR used in this Function App."
}

variable "functions_runtime_version" {
  type        = string
  description = "The version of the Functions runtime that hosts your function app (https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings#functions_extension_version)."
}

variable "ip_restrictions" {
  type = list(
    object(
      {
        action      = optional(string)
        description = string
        headers = optional(list(
          object(
            {
              front_door_ids          = list(string)
              front_door_health_probe = list(string)
              forwarded_for           = list(string)
              forwarded_host          = list(string)
            }
          )
        ))
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
      }
    )
  )
  default     = []
  description = "A list of ip restrictions for inbound access to the Function App."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The Azure resource identifier for a Log Analytics Workspace that Application Insight instances will be attached to."
}

variable "location" {
  type        = string
  description = "The Azure region where the function app will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Function App will be created."
}

variable "role" {
  type        = string
  description = "Defines a role name for the Function App so it can be referred to by this name when attaching to an App Service Plan."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "The identifier of the subnet that Function App will be associated to."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "use_32_bit_worker_process" {
  type        = bool
  default     = true
  description = "If the Function App should run in 32 bit mode, rather than 64 bit mode."
}

# we could trigger vnet integration based on whether a valid subnet_id is passed or not.
# this would typically be done using a for_each or count on the value of the subnet_id and
# simply not create the vnet integration if it is null or empty. unfortunately, in some cases
# the subnet_id would not be known until after an apply operation so terraform would give an error
# like 'The "count" value depends on resource attributes that cannot be determined until apply'.
# to get around that issue, this flag is used to trigger vnet integration because it is a simple
# bool value that is known before apply.
variable "vnet_integration_enabled" {
  type        = bool
  description = "Determines if the App Service will be integrated into a virtual network."
}

variable "vnet_route_all_enabled" {
  type        = bool
  default     = true
  description = "Apply network security group rules and user defined routes to all outbound function app traffic."
}

variable "worker_runtime_type" {
  type        = string
  description = "The language worker runtime to load in the function app. This corresponds to the language being used in your application. For example, dotnet. (https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings#functions_worker_runtime)"
}

variable "workspace_id" {
  type        = string
  default     = null
  description = "The Azure resource identifier for a Log Analytics Workspace that the Application Insights for the App Service will be attached to."
}
