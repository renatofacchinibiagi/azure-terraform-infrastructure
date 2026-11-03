output "resource_group_name" {
  description = "Resource Group dedicado ao armazenamento do state."
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "Storage Account que hospeda o container de state."
  value       = azurerm_storage_account.state.name
}

output "container_name" {
  description = "Container privado para os arquivos de state."
  value       = azurerm_storage_container.state.name
}
