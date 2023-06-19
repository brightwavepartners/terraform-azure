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

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the service bus is provisioned."
}
