# ======================
# ВИХОДИ DEV СЕРЕДОВИЩА
# ======================

# ======================
# VPC ВИХОДИ
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
# ECR ВИХОДИ
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
# EKS ВИХОДИ
# ======================
output "eks_cluster_endpoint" {
  description = "EKS API ендпоінт для підключення до кластера"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "ARN IAM ролі для EKS робочих вузлів"
  value       = module.eks.eks_node_role_arn
}

output "oidc_provider_arn" {
  description = "ARN OIDC провайдера"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL OIDC провайдера"
  value       = module.eks.oidc_provider_url
}

# ======================
# RDS ВИХОДИ  
# ======================

output "db_instance_endpoint" {
  description = "Ендпоінт RDS інстансу"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_hostname" {
  description = "Хостнейм RDS інстансу"
  value       = module.rds.db_instance_hostname
}

output "db_instance_port" {
  description = "Порт RDS інстансу"
  value       = module.rds.db_instance_port
}

output "db_instance_name" {
  description = "Назва бази даних RDS інстансу"
  value       = module.rds.db_instance_name
}

output "database_url" {
  description = "URL підключення до бази даних"
  value       = module.rds.database_url
  sensitive   = true
}

# ======================
# ІНФОРМАЦІЯ ПРО СЕРЕДОВИЩЕ
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
