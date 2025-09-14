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
  default     = true # для dev
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
# GITHUB КОНФІГУРАЦІЯ
# ======================

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

# ======================
# RDS КОНФІГУРАЦІЯ
# ======================

variable "name" {
  description = "Назва інстансу або кластера"
  type        = string
  default     = "djangodb"
}

variable "use_aurora" {
  description = "Чи використовувати Aurora (true) або стандартний RDS (false)"
  type        = bool
  default     = false
}

variable "max_allocated_storage" {
  description = "Максимально виділений об'єм сховища (тільки для стандартного RDS)"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Назва бази даних"
  type        = string
  default     = "djangodb"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default     = "TempPassword123!"
}

# Engine settings
variable "engine" {
  description = "Engine для стандартного RDS"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія engine для стандартного RDS"
  type        = string
  default     = "14.19"
}

variable "engine_cluster" {
  description = "Engine для Aurora кластера"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_cluster" {
  description = "Версія engine для Aurora кластера"
  type        = string
  default     = "15.14"
}

variable "instance_class" {
  description = "Клас інстансу БД"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Виділений об'єм сховища (тільки для стандартного RDS)"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Увімкнути Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Чи має бути база доступна публічно"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Кількість днів для збереження бекапів"
  type        = number
  default     = 7
}

# Aurora replicas
variable "aurora_replica_count" {
  description = "Кількість Aurora read replicas"
  type        = number
  default     = 1
}

# Parameter groups
variable "parameter_group_family_rds" {
  description = "Сімейство parameter group для стандартного RDS"
  type        = string
  default     = "postgres14"
}

variable "parameter_group_family_aurora" {
  description = "Сімейство parameter group для Aurora"
  type        = string
  default     = "aurora-postgresql15"
}

variable "parameters" {
  description = "Додаткові параметри для parameter group"
  type        = map(string)
  default     = {}
}