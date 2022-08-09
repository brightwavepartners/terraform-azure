variable "app_service_plan_id" {}

variable "location" {}

variable "resource_group_name" {}

variable "settings" {
  type = object(
    {
      diagnostics_settings = optional(list(
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
      enabled = bool
      name    = string
      notification = object(
        {
          email = object(
            {
              recipients                            = list(string),
              send_to_subscription_administrator    = bool
              send_to_subscription_co_administrator = bool
            }
          )
        }
      ),
      profiles : list(
        object(
          {
            name = string
            capacity = object(
              {
                default = number
                minimum = number
                maximum = number
              }
            ),
            rules = list(
              object(
                {
                  name             = string
                  operator         = string
                  statistic        = string
                  threshold        = number
                  time_aggregation = string
                  time_grain       = string
                  time_window      = string
                  action = object(
                    {
                      cooldown  = string
                      direction = string
                      type      = string
                      value     = string
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
}

variable "tags" {}
