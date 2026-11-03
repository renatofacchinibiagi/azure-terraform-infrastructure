variable "subscription_id" {
  description = "ID da subscription Azure onde o backend será criado."
  type        = string
}

variable "location" {
  description = "Região Azure para o Resource Group e a Storage Account."
  type        = string
  default     = "brazilsouth"
}

variable "resource_group_name" {
  description = "Nome do Resource Group dedicado ao state do Terraform."
  type        = string
  default     = "rg-tfstate-bootstrap-prod"
}

variable "storage_account_name" {
  description = "Nome globalmente único da Storage Account (3 a 24 caracteres, minúsculos e números)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "O nome deve conter de 3 a 24 caracteres, usando apenas letras minúsculas e números."
  }
}

variable "container_name" {
  description = "Container privado que armazenará os states do Terraform."
  type        = string
  default     = "tfstate"
}

variable "account_replication_type" {
  description = "Replicação da Storage Account. ZRS oferece redundância entre zonas onde disponível."
  type        = string
  default     = "ZRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Use um tipo de replicação Standard suportado: LRS, ZRS, GRS, RAGRS, GZRS ou RAGZRS."
  }
}
