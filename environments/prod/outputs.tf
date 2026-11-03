output "resource_group_name" {
  description = "Nome do Resource Group do ambiente."
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID do Resource Group do ambiente."
  value       = module.resource_group.id
}

output "vnet_name" {
  description = "Nome da VNet do ambiente."
  value       = module.network.vnet_name
}

output "subnet_ids" {
  description = "IDs das subnets do ambiente."
  value       = module.network.subnet_ids
}
