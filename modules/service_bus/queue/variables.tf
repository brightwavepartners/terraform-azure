variable "namespace_name" {
  type        = string
  description = "The name of the ServiceBus Namespace to create this queue in."
}

variable "queue" {
  type = object(
    {
      enable_batched_operations = bool,
      name                      = string,
    }
  )
}
