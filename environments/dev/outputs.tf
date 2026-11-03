output "resource_group_name" {
  description = "Nome do Resource Group do ambiente."
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID do Resource Group do ambiente."
  value       = module.resource_group.id
}
