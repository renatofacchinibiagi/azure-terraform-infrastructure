variable "subscription_id" {
  description = "ID da subscription do Azure."
  type        = string
}

variable "location" {
  description = "Região do Azure."
  type        = string
  default     = "brazilsouth"
}

variable "environment" {
  description = "Nome do ambiente."
  type        = string
  default     = "prod"
}

variable "workload" {
  description = "Nome curto da carga de trabalho, usado na nomenclatura dos recursos."
  type        = string
  default     = "portfolio"
}
