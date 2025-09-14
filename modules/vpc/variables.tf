# ======================
# VPC MODULE VARIABLES
# ======================

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "vpc_cidr_block має бути валідним CIDR блоком."
  }
}

variable "vpc_name" {
  description = "Назва VPC"
  type        = string
}

variable "public_subnets" {
  description = "Список CIDR блоків для публічних підмереж"
  type        = list(string)
  
  validation {
    condition = alltrue([
      for subnet in var.public_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "Всі публічні підмережі мають бути валідними CIDR блоками."
  }
}

variable "private_subnets" {
  description = "Список CIDR блоків для приватних підмереж"
  type        = list(string)
  
  validation {
    condition = alltrue([
      for subnet in var.private_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "Всі приватні підмережі мають бути валідними CIDR блоками."
  }
}

variable "availability_zones" {
  description = "Список зон доступності"
  type        = list(string)
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Потрібно мінімум 2 зони доступності для високої доступності."
  }
}

variable "tags" {
  description = "Теги для ресурсів VPC"
  type        = map(string)
  default     = {}
}