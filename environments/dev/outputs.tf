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
# RDS ВИХОДИ - УНІВЕРСАЛЬНИЙ МОДУЛЬ
# ======================

output "rds_endpoint" {
  description = "RDS endpoint для підключення"
  value       = module.rds.rds_endpoint
}

output "rds_hostname" {
  description = "RDS hostname"
  value       = module.rds.rds_hostname
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.rds_port
}

output "database_name" {
  description = "Назва бази даних"
  value       = module.rds.database_name
}

output "database_url" {
  description = "URL підключення до бази даних"
  value       = module.rds.database_url
  sensitive   = true
}

output "rds_type" {
  description = "Тип RDS (Aurora або Standard)"
  value       = var.use_aurora ? "Aurora Cluster" : "Standard RDS"
}

output "security_group_id" {
  description = "ID групи безпеки RDS"
  value       = module.rds.security_group_id
}

# Aurora specific outputs (буде null якщо не Aurora)
output "aurora_cluster_id" {
  description = "ID Aurora кластера (null якщо стандартний RDS)"
  value       = module.rds.aurora_cluster_id
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint Aurora кластера (null якщо стандартний RDS)"
  value       = module.rds.aurora_reader_endpoint
}

# Backward compatibility outputs
output "db_instance_endpoint" {
  description = "(Deprecated) Використовуйте rds_endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_hostname" {
  description = "(Deprecated) Використовуйте rds_hostname"
  value       = module.rds.db_instance_hostname
}

output "db_instance_port" {
  description = "(Deprecated) Використовуйте rds_port"
  value       = module.rds.db_instance_port
}

output "db_instance_name" {
  description = "(Deprecated) Використовуйте database_name"
  value       = module.rds.db_instance_name
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


# ======================
# JENKINS OUTPUTS
# ======================

output "jenkins_release" {
  description = "Jenkins release name"
  value       = module.jenkins.jenkins_release_name
}
output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = module.jenkins.jenkins_namespace
}

# ======================
# ARGOCD OUTPUTS
# ======================

output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = module.argo_cd.namespace
}
output "argocd_server_service" {
  description = "ArgoCD server service"
  value       = module.argo_cd.argo_cd_server_service
}
output "argocd_admin_password" {
  description = "Initial admin password"
  value       = module.argo_cd.admin_password
}

# ======================
# MONITORING OUTPUTS
# ======================

output "prometheus_url" {
  description = "Prometheus server URL"
  value       = module.monitoring.prometheus_url
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = module.monitoring.grafana_url
}

output "grafana_admin_user" {
  description = "Grafana admin username"
  value       = "admin"
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = module.monitoring.grafana_admin_password
  sensitive   = true
}

output "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring"
  value       = module.monitoring.monitoring_namespace
}