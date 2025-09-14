# ======================
# УНІВЕРСАЛЬНИЙ RDS MODULE VARIABLES  
# ======================

# Основна конфігурація
variable "name" {
  description = "Назва інстансу або кластера"
  type        = string
}

variable "max_allocated_storage" {
  description = "Максимально виділений об'єм сховища (тільки для стандартного RDS)"
  type        = number
  default     = 100
}

variable "use_aurora" {
  description = "Використовувати Aurora (true) або стандартний RDS (false)"
  type        = bool
  default     = false
}

# Конфігурація бази даних
variable "db_name" {
  description = "Назва бази даних"
  type        = string
}

variable "username" {
  description = "Майстер username для бази даних"
  type        = string
}

variable "password" {
  description = "Майстер пароль для бази даних"
  type        = string
  sensitive   = true
}

# Конфігурація engine
variable "engine" {
  description = "Engine для стандартного RDS"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія engine для стандартного RDS"
  type        = string
  default     = "15.8"
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

# Конфігурація інстансів
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

# Мережеві налаштування
variable "vpc_id" {
  description = "ID VPC де буде розгорнуто RDS"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
}

variable "subnet_private_ids" {
  description = "Список ID приватних підмереж"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "Список ID публічних підмереж"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Чи має бути база доступна публічно"
  type        = bool
  default     = false
}

# Налаштування високої доступності
variable "multi_az" {
  description = "Увімкнути Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "aurora_replica_count" {
  description = "Кількість Aurora read replicas"
  type        = number
  default     = 1
}

# Налаштування резервного копіювання
variable "backup_retention_period" {
  description = "Період утримання резервних копій (в днях)"
  type        = number
  default     = 7
}

# Parameter Groups
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
  default = {
    max_connections = "200"
    log_statement   = "none"
    work_mem        = "4096"
  }
}

# Теги
variable "tags" {
  description = "Теги для застосування до RDS ресурсів"
  type        = map(string)
  default     = {}
}