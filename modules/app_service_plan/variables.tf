variable "alert_settings" {
  type = list(
    object(
      {
        action = object(
          {
            action_group_id = string
          }
        )
        description = string
        dynamic_criteria = optional(
          object(
            {
              aggregation              = string
              alert_sensitivity        = string
              evaluation_failure_count = optional(number)
              evaluation_total_count   = optional(number)
              metric_name              = string
              operator                 = string
            }
          )
        )
        enabled   = bool
        frequency = optional(string)
        name      = string
        severity  = number
        static_criteria = optional(
          object(
            {
              aggregation = string
              metric_name = string
              operator    = string
              threshold   = number
            }
          )
        )
        window_size = optional(string)
      }
    )
  )
  default     = []
  description = "Defines alert settings for the Function App."
}

variable "application" {
  type        = string
  description = "The name of the application that this infrastructure is being provisioned for."
}

variable "diagnostics_settings" {
  type = list(
    object(
      {
        name = string
        destination = object(
          {
            log_analytics_workspace = optional(
              object(
                {
                  destination_type = optional(string)
                  id               = string
                }
              )
            )
          }
        )
        logs = optional(
          list(
            object(
              {
                category = string
                enabled  = bool
                retention = object(
                  {
                    days    = number
                    enabled = bool
                  }
                )
              }
            )
          )
        )
        metrics = optional(
          list(
            object(
              {
                category = string
                enabled  = bool
                retention = object(
                  {
                    days    = number
                    enabled = bool
                  }
                )
              }
            )
          )
        )
      }
    )
  )
  default     = []
  description = "Defines the configuration for diagnostics settings on the App Service Plan."
}

variable "environment" {
  type        = string
  description = "The environment for which to provision the infrastructure (e.g. development, production)"
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

variable "os_type" {
  type        = string
  default     = "Windows"
  description = "The kind of App Service Plan to create."
  validation {
    condition     = try(index(["Linux", "Windows", "WindowsContainer"], var.os_type), -1) >= 0 ? true : false
    error_message = "Expected sku to be one of [Linux Windows WindowsContainer], got ${var.os_type}."
  }
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
        diagnostics_settings = optional(
          list(
            object(
              {
                destination = object(
                  {
                    log_analytics_workspace = optional(
                      object(
                        {
                          destination_type = optional(string)
                          id               = string
                        }
                      )
                    )
                  }
                )
                name = string
                logs = list(
                  object(
                    {
                      category = string
                      enabled  = bool
                      retention = object(
                        {
                          days    = number
                          enabled = bool
                        }
                      )
                    }
                  )
                ),
                metrics = list(
                  object(
                    {
                      category = string
                      enabled  = bool
                      retention = object(
                        {
                          days    = number
                          enabled = bool
                        }
                      )
                    }
                  )
                )
              }
            )
        )),
        enabled = bool,
        name    = string,
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
  default     = []
  description = "Defines how the App Service Plan should automatically scale."
}

variable "sku_name" {
  type = string
  description = "The SKU for the plan."
  validation {
    condition     = try(index([
      "B1",
      "B2",
      "B3",
      "D1",
      "F1",
      "I1",
      "I2",
      "I3",
      "I1v2",
      "I2v2",
      "I3v2",
      "P1v2",
      "P2v2",
      "P3v2",
      "P1v3",
      "P2v3",
      "P3v3",
      "S1",
      "S2",
      "S3",
      "SHARED",
      "EP1",
      "EP2",
      "EP3",
      "WS1",
      "WS2",
      "WS3",
      "Y1"], var.sku_name), -1) >= 0 ? true : false
    error_message = "Expected sku_name to be one of [B1 B2 B3 D1 F1 I1 I2 I3 I1v2 I2v2 I3v2 P1v2 P2v2 P3v2 P1v3 P2v3 P3v3 S1 S2 S3 SHARED EP1 EP2 EP3 WS1 WS2 WS3 Y1], got ${var.sku_name}."
  }  
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
