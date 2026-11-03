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
  default     = "dev"
}

variable "workload" {
  description = "Nome curto da carga de trabalho, usado na nomenclatura dos recursos."
  type        = string
  default     = "portfolio"
}

variable "vnet_address_space" {
  description = "Faixas de endereços (CIDR) da VNet."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnets" {
  description = "Subnets da VNet. A chave do mapa é o nome da subnet."
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {
    "snet-app"  = { address_prefixes = ["10.10.1.0/24"] }
    "snet-data" = { address_prefixes = ["10.10.2.0/24"] }
  }
}
