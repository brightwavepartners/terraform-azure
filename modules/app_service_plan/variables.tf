variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
}

variable "kind" {
  type        = string
  description = "The kind of App Service Plan to create."
}

variable "location" {
  type        = string
  description = "The Azure region where the app service will be deployed."
}

variable "maximum_elastic_worker_count" {
  type        = number
  default     = 1
  description = "The maximum number of total workers allowed if this is an Elastic App Service Plan."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the app service will be created."
}

variable "role" {
  type        = string
  description = "Defines a role name for the App Service Plan so it can be referred to by this name when attaching to an App Service."
}

variable "scale_settings" {
  type = list(
    object(
      {
        enabled = bool,
        name = string,
        notification = object(
          {
            email = object(
              {
                recipients                            = list(string),
                send_to_subscription_administrator    = bool,
                send_to_subscription_co_administrator = bool
              }
            )
          }
        )
        profiles = list(
          object(
            {
              name = string,
              capacity = object(
                {
                  default = number,
                  minimum = number,
                  maximum = number
                }
              ),
              rules = list(
                object(
                  {
                    name             = string,
                    operator         = string,
                    statistic        = string,
                    threshold        = number,
                    time_aggregation = string,
                    time_grain       = string,
                    time_window      = string,
                    action = object(
                      {
                        cooldown  = string,
                        direction = string,
                        type      = string,
                        value     = number
                      }
                    )
                  }
                )
              )
            }
          )
        )
      }
    )
  )
  description = "Defines how the App Service Plan should automatically scale."
  default     = []
}

variable "size" {
  type        = string
  description = "Specifies the App Service Plan's instance size."
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources."
}

variable "tenant" {
  type        = string
  description = "Tenant name."
}

variable "tier" {
  type        = string
  description = "Specifies the App Service Plan's pricing tier."
}
