output "id" {
  value       = azurerm_redis_cache.redis_cache.id
  description = "The Azure resource identifier of the Redis Cache."
}

output "location" {
  value       = azurerm_redis_cache.redis_cache.location
  description = "The Azure region in which the Redis Cache was provisioned."
}

output "name" {
  value       = azurerm_redis_cache.redis_cache.name
  description = "The name of the Redis Cache."
}

output "primary_access_key" {
  value       = azurerm_redis_cache.redis_cache.primary_access_key
  description = "The primary access key needed to gain access to the Redis Cache."
}