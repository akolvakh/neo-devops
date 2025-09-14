# ======================
# DEV ENVIRONMENT OUTPUTS
# ======================

# ======================
# VPC OUTPUTS
# ======================

output "vpc_id" {
  description = "ID створеного VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR блок VPC"
  value       = local.vpc_cidr
}

output "public_subnets" {
  description = "Список ID публічних підмереж"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Список ID приватних підмереж"
  value       = module.vpc.private_subnets
}

output "availability_zones" {
  description = "Використані зони доступності"
  value       = slice(local.availability_zones, 0, var.subnet_count)
}

# ======================
# ECR OUTPUTS
# ======================

output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.ecr_repo_url
}

output "ecr_repository_name" {
  description = "Назва ECR репозиторію"
  value       = "${local.resource_prefix}-ecr"
}

# ======================
# ENVIRONMENT INFO
# ======================

output "project_name" {
  description = "Назва проекту"
  value       = var.project_name
}

output "environment" {
  description = "Середовище розгортання"
  value       = var.environment
}

output "aws_region" {
  description = "AWS регіон"
  value       = data.aws_region.current.id
}

output "resource_prefix" {
  description = "Префікс для ресурсів"
  value       = local.resource_prefix
}
