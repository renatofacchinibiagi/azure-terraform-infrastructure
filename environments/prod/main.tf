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
