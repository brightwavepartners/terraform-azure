variable "alert_settings" {
  type = object(
    {
      action = object(
        {
          action_group_id = string
        }
      )
      static_criteria = optional(
        object(
          {
            aggregation      = string
            metric_name      = string
            metric_namespace = string
            operator         = string
            threshold        = number

            dimensions = optional(
              list(
                object(
                  {
                    name     = string
                    operator = string
                    values   = list(string)
                  }
                )
              )
            )
          }
        )
      )
      dynamic_criteria = optional(
        object(
          {
            aggregation              = string
            alert_sensitivity        = string
            evaluation_failure_count = optional(number)
            evaluation_total_count   = optional(number)
            metric_name              = string
            metric_namespace         = string
            operator                 = string

            dimensions = optional(
              list(
                object(
                  {
                    name     = string
                    operator = string
                    values   = list(string)
                  }
                )
              )
            )
          }
        )
      )

      description         = string
      enabled             = bool
      frequency           = optional(string)
      name                = string
      resource_group_name = string
      scopes              = list(string)
      severity            = number
      tags                = map(string)
      window_size         = optional(string)
    }
  )
  description = "Describes how to configure the alert."
}
