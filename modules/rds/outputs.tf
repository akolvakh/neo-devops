output "database_url" {
  value = "postgres://${var.db_user}:${var.db_password}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${var.db_name}"
  description = "Рядок підключення до PostgreSQL бази даних"
  sensitive = true
}

output "db_instance_endpoint" {
  description = "Ендпоінт RDS інстансу"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_hostname" {
  description = "Хостнейм RDS інстансу"
  value       = aws_db_instance.postgres.address
}

output "db_instance_port" {
  description = "Порт RDS інстансу"
  value       = aws_db_instance.postgres.port
}

output "db_instance_name" {
  description = "Назва бази даних RDS інстансу"
  value       = aws_db_instance.postgres.db_name
}

output "security_group_id" {
  description = "ID групи безпеки"
  value       = aws_security_group.rds.id
}
