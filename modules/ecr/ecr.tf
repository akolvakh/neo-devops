# Створення ECR репозиторію
resource "aws_ecr_repository" "ecr" {
  name                 = var.ecr_name               # Назва репозиторію
  image_tag_mutability = var.image_tag_mutability   # Можливість змінювати теги
  force_delete         = var.force_delete           # Примусове видалення

  # Налаштування сканування образів
  image_scanning_configuration {
    scan_on_push = var.scan_on_push                 # Сканувати при завантаженні
  }

  tags = {
    Name = var.ecr_name
  }
}

variable "repository_policy" {
  description = "Опціональна кастомна JSON політика для ECR репозиторію"
  type        = string
  default     = null
}

# Політика доступу до репозиторію
resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name          # Назва репозиторію
  policy     = coalesce(var.repository_policy, local.default_policy) # Використати кастомну або дефолтну політику
}
