# ======================
# S3 BACKEND MODULE VARIABLES
# ======================

variable "bucket_name" {
  description = "Назва S3 bucket для зберігання Terraform state"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Назва bucket має відповідати AWS naming conventions."
  }
}

variable "dynamodb_table" {
  description = "Назва DynamoDB таблиці для state locking"
  type        = string
}

variable "env_name" {
  description = "Назва середовища"
  type        = string
  default     = "dev"
}

variable "enable_versioning" {
  description = "Увімкнути версіонування S3 bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Дозволити видалення bucket з об'єктами"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Теги для ресурсів S3 backend"
  type        = map(string)
  default     = {}
}
