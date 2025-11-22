# ======================
# RDS MODULE OUTPUTS
# ======================

# Універсальний endpoint (працює для обох типів)
output "rds_endpoint" {
  description = "RDS endpoint для підключення до бази даних"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.postgres[0].endpoint
}

# Універсальний hostname
output "rds_hostname" {
  description = "RDS hostname"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.postgres[0].address
}

# Універсальний port
output "rds_port" {
  description = "RDS port"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.postgres[0].port
}

# Назва бази даних
output "database_name" {
  description = "Назва бази даних"
  value       = var.db_name
}

# Connection string
# output "database_url" {
#   description = "Рядок підключення до бази даних"
#   value = var.use_aurora ? "postgres://${var.username}:${var.password}@${aws_rds_cluster.aurora[0].endpoint}:${aws_rds_cluster.aurora[0].port}/${var.db_name}" : "postgres://${var.username}:${var.password}@${aws_db_instance.postgres[0].address}:${aws_db_instance.postgres[0].port}/${var.db_name}"
#   sensitive   = true
# }


output "database_url" {
  value = "postgres://${var.username}:${var.password}@${aws_db_instance.postgres[0].address}:${aws_db_instance.postgres[0].port}/${var.db_name}"
  description = "Рядок підключення до PostgreSQL бази даних"
  sensitive = true
}

# Security Group ID
output "security_group_id" {
  description = "ID групи безпеки RDS"
  value       = aws_security_group.rds.id
}

# Subnet Group name
output "subnet_group_name" {
  description = "Назва DB subnet group"
  value       = aws_db_subnet_group.main.name
}

# Aurora specific outputs
output "aurora_cluster_id" {
  description = "ID Aurora кластера (якщо використовується Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].id : null
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint Aurora кластера (якщо використовується Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

# Standard RDS specific outputs
output "standard_rds_id" {
  description = "ID стандартного RDS інстансу (якщо використовується стандартний RDS)"
  value       = var.use_aurora ? null : aws_db_instance.postgres[0].id
}

# Deprecated outputs for backward compatibility
output "db_instance_endpoint" {
  description = "(Deprecated) Використовуйте rds_endpoint"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.postgres[0].endpoint
}

output "db_instance_hostname" {
  description = "(Deprecated) Використовуйте rds_hostname"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.postgres[0].address
}

output "db_instance_port" {
  description = "(Deprecated) Використовуйте rds_port"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.postgres[0].port
}

output "db_instance_name" {
  description = "(Deprecated) Використовуйте database_name"
  value       = var.db_name
}