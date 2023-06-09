output "elastic_pools" {
    value = module.elastic_pools
    description = "Elastic pools that were provisioned within the SQL Server while the server was being provisioned."
}

output "id" {
    value = azurerm_mssql_server.sql_server.id
    description = "The unique Azure resource identifier for the provisioned SQL server."
}

output "name" {
    value = azurerm_mssql_server.sql_server.name
    description = "The name applied to the SQL server when it was provisioned."
}