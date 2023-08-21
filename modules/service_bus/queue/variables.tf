variable "namespace_id" {
  type        = string
  description = "The unique Azure resource identifier for the Service Bus namespace to which the queue will be attached."
}

variable "queue" {
  type = object(
    {
      enable_batched_operations = bool,
      name                      = string,
    }
  )
}

