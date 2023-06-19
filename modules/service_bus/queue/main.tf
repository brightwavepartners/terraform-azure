resource "azurerm_servicebus_queue" "example" {
  enable_batched_operations = var.queue.enable_batched_operations
  name                      = var.queue.name
  namespace_id              = var.namespace_id
}
