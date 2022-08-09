variable "namespace_id" {
  type        = string
  description = "The unique Azure resource identifier for the Service Bus namespace to which the topic will be attached."
}

variable "topic" {
  type = object(
    {
      enable_batched_operations = bool,
      name                      = string,
      policies = list(
        object(
          {
            name = string,
            claims = object(
              {
                listen = bool,
                manage = bool,
                send   = bool
              }
            )
          }
        )
      ),
      support_ordering = bool
    }
  )
  description = "The topics to create on the Service Bus."
}
