output "name" {
  description = "Nome do Resource Group."
  value       = azurerm_resource_group.this.name
}

output "id" {
  description = "ID do Resource Group."
  value       = azurerm_resource_group.this.id
}

output "location" {
  description = "Região do Resource Group."
  value       = azurerm_resource_group.this.location
}
