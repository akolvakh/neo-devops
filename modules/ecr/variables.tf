variable "ecr_name" {
  description = "Назва репозиторію"
  type        = string
}

variable "force_delete" {
  description = "Булева змінна - видаляти чи ні"
  type        = bool
  default     = true
}

variable "scan_on_push" {
  description = "Булева змінна - сканувати при завантаженні чи ні"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "MUTABLE / IMMUTABLE тег"
  type        = string
  default     = "MUTABLE"
}
