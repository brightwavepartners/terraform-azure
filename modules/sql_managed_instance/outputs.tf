output "route_table" {
  value       = azurerm_route_table.routetable
  description = "The route table that manages network routing for the SQL Managed Instance."
}