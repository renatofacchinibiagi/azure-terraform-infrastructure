terraform {
  # State remoto no container criado no bootstrap, com chave própria deste ambiente.
  # resource_group_name, storage_account_name e container_name vêm do -backend-config no init.
  backend "azurerm" {
    key              = "dev/terraform.tfstate"
    use_azuread_auth = true
  }
}
