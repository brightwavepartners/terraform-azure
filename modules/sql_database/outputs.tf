output "id" {
  value       = azurerm_mssql_database.database.id
  description = "The unique Azure identifier for the database."
}

output "name" {
  value       = azurerm_mssql_database.database.name
  description = "The name that was assigned to the database while provisioning."
}
