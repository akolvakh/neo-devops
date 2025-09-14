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
  default     = "TempPassword123!"
}

variable "vpc_id" {
  description = "ID VPC де буде розгорнуто RDS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Список ID приватних підмереж для RDS"
  type        = list(string)
}

variable "tags" {
  description = "Теги для застосування до RDS ресурсів"
  type        = map(string)
  default     = {}
}
