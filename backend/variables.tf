# ======================
# BACKEND VARIABLES
# ======================

variable "aws_region" {
  description = "AWS регіон для backend ресурсів"
  type        = string
  default     = "us-east-1"
}

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

variable "enable_s3_versioning" {
  description = "Увімкнути версіонування S3 bucket"
  type        = bool
  default     = true
}

variable "s3_bucket_force_destroy" {
  description = "Дозволити видалення bucket з об'єктами (тільки для dev!)"
  type        = bool
  default     = false
}
