# ======================
# DEV ENVIRONMENT VARIABLES
# ======================

# ======================
# PROJECT CONFIGURATION
# ======================

variable "project_name" {
  description = "Назва проєкту"
  type        = string
  default     = "lesson-5"
}

variable "environment" {
  description = "Середовище (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Середовище має бути одним із: dev, staging, prod."
  }
}

variable "owner" {
  description = "Власник ресурсів"
  type        = string
  default     = "akolvakh"
}

variable "aws_region" {
  description = "AWS регіон"
  type        = string
  default     = "us-east-1"
}

# ======================
# NETWORKING
# ======================

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "vpc_cidr_block має бути валідним CIDR блоком."
  }
}

variable "subnet_count" {
  description = "Кількість підмереж для створення"
  type        = number
  default     = 3
  
  validation {
    condition     = var.subnet_count >= 2 && var.subnet_count <= 6
    error_message = "subnet_count має бути між 2 та 6."
  }
}

# ======================
# ECR CONFIGURATION
# ======================

variable "ecr_force_delete" {
  description = "Дозволити видалення ECR репозиторію з образами"
  type        = bool
  default     = true  # для dev
}

variable "ecr_scan_on_push" {
  description = "Увімкнути сканування образів на вразливості"
  type        = bool
  default     = true
}

variable "ecr_image_tag_mutability" {
  description = "Тип мутабельності тегів (MUTABLE або IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability має бути MUTABLE або IMMUTABLE."
  }
}


# ======================
# EKS КОНФІГУРАЦІЯ
# ======================
variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
  default     = "eks-cluster-lesson-7"
}

variable "instance_type" {
  description = "Тип EC2 інстансів для EKS робочих вузлів"
  type        = string
  default     = "t3.medium"
}

# ======================
# RDS КОНФІГУРАЦІЯ
# ======================

variable "db_name" {
  description = "Назва бази даних"
  type        = string
  default     = "djangodb"
}

variable "db_user" {
  description = "Головне ім'я користувача бази даних"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Головний пароль бази даних"
  type        = string
  sensitive   = true
  default     = "TempPassword123!"  # В продакшні використовувати secrets
}


// github credentials
variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
}
variable "github_user" {
  description = "GitHub username"
  type        = string
}
variable "github_repo_url" {
  description = "GitHub repository name"
  type        = string
}