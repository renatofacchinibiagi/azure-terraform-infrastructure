variable "name" {
  description = "Nome da Virtual Network."
  type        = string
}

variable "location" {
  description = "Região do Azure onde a VNet será criada."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group onde a VNet será criada."
  type        = string
}

variable "address_space" {
  description = "Faixas de endereços (CIDR) da VNet."
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "Todos os valores de address_space devem ser CIDRs válidos, por exemplo 10.10.0.0/16."
  }
}

variable "subnets" {
  description = "Subnets da VNet. A chave do mapa é o nome da subnet."
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue(flatten([for s in var.subnets : [for cidr in s.address_prefixes : can(cidrhost(cidr, 0))]]))
    error_message = "Todos os address_prefixes das subnets devem ser CIDRs válidos, por exemplo 10.10.1.0/24."
  }
}

variable "tags" {
  description = "Tags aplicadas à VNet."
  type        = map(string)
  default     = {}
}
