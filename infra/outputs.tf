output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

output "db_server_fqdn" {
  description = "Public FQDN of the database server (not used if Private Endpoint is active)"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "db_private_endpoint_ids" {
  description = "IDs of PostgreSQL private endpoints"
  value       = azurerm_private_endpoint.db[*].id
  sensitive   = true
}

output "private_dns_zone_name" {
  description = "Private DNS Zone used for integration"
  value       = azurerm_private_dns_zone.db.name
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value = {
    app     = azurerm_subnet.app.id
    db      = azurerm_subnet.db.id
    private = azurerm_subnet.pe.id
  }
}
