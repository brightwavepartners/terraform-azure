locals {
  topic_policies = var.topic.policies == null ? [] : var.topic.policies
}

resource "azurerm_servicebus_topic" "topic" {
  enable_batched_operations = var.topic.enable_batched_operations
  name                      = var.topic.name
  namespace_id              = var.namespace_id
  support_ordering          = var.topic.support_ordering
}

resource "azurerm_servicebus_topic_authorization_rule" "authorization_rules" {
  for_each = {
    for policy in local.topic_policies : policy.name => policy
  }

  name     = each.value.name
  topic_id = azurerm_servicebus_topic.topic.id
  listen   = each.value.claims.listen
  send     = each.value.claims.send
  manage   = each.value.claims.manage
}
