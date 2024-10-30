variable "settings" {
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
              }
            )
          )
        )
        metrics = optional(
          list(
            object(
              {
                category = string
              }
            )
          )
        )
      }
    )
  )
  default     = []
  description = "Defines the configuration for diagnostics settings."
}

variable "target_resource_id" {
  type        = string
  description = "The Azure identifier of the resource to which the diagnostics settings should be attached."
}
