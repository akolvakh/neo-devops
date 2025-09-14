# ======================
# СТАНДАРТНИЙ RDS INSTANCE
# ======================

# Standard RDS Instance
resource "aws_db_instance" "postgres" {
  count                   = var.use_aurora ? 0 : 1
  identifier              = "${var.db_name}-postgres"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  max_allocated_storage   = var.max_allocated_storage
  parameter_group_name    = aws_db_parameter_group.standard[0].name
  # parameter_group_name    = "default.postgres15"
  skip_final_snapshot     = true # Для dev середовища
  storage_encrypted       = true    # Шифрування сховища
  
  # Performance Insights для моніторингу
  performance_insights_enabled = true
  
  tags = merge(var.tags, {
    Name = "${var.name}-postgres"
  })
}

# Standard parameter group
resource "aws_db_parameter_group" "standard" {
  count       = var.use_aurora ? 0 : 1
  name        = "${var.name}-rds-params"
  family      = var.parameter_group_family_rds
  description = "Standard RDS PG for ${var.name}"
  
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }
  
  tags = var.tags
}