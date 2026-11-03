variable "name" {
  description = "Nome do Resource Group."
  type        = string
}

variable "location" {
  description = "Região do Azure onde o Resource Group será criado."
  type        = string
}

variable "tags" {
  description = "Tags aplicadas ao Resource Group."
  type        = map(string)
  default     = {}
}
