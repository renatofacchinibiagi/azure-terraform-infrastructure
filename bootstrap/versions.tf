terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2, < 5.0"
    }
  }

  # Backend remoto ativo (etapa de migração). No primeiro apply ele ficava comentado.
  backend "azurerm" {
    key              = "bootstrap/terraform.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}
