locals {
  tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "azure-terraform-infrastructure"
  }
}

module "resource_group" {
  source = "../../modules/resource-group"

  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../../modules/network"

  name                = "vnet-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.tags
}
