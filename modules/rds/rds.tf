# Група підмереж для бази даних
resource "aws_db_subnet_group" "main" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.db_name}-subnet-group"
  })
}

# Група безпеки для RDS
resource "aws_security_group" "rds" {
  name        = "${var.db_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  # Дозволити PostgreSQL з EKS вузлів
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Дозволити доступ з VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.db_name}-rds-sg"
  })
}

# RDS Інстанс
resource "aws_db_instance" "postgres" {
  identifier = "${var.db_name}-postgres"
  
  allocated_storage      = 20      # Виділений обсяг сховища
  max_allocated_storage  = 100     # Максимальний обсяг для автоскейлінгу
  storage_type           = "gp3"   # Тип сховища
  storage_encrypted      = true    # Шифрування сховища
  
  engine         = "postgres"      # Движок БД
  engine_version = "15.8"          # Версія PostgreSQL
  instance_class = "db.t3.micro"   # Клас інстансу
  
  db_name  = var.db_name          # Назва БД
  username = var.db_user          # Ім'я користувача
  password = var.db_password      # Пароль
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  # Налаштування безпеки
  publicly_accessible = false      # Більш безпечно - немає публічного доступу
  skip_final_snapshot = true       # Для dev середовища - пропустити фінальний снапшот
  
  # Налаштування резервного копіювання
  backup_retention_period = 7                    # Тримати бекапи 7 днів
  backup_window          = "03:00-04:00"         # Вікно для бекапів
  maintenance_window     = "Sun:04:00-Sun:05:00" # Вікно для технічного обслуговування
  
  # Performance Insights для моніторингу
  performance_insights_enabled = true
  
  tags = merge(var.tags, {
    Name = "${var.db_name}-postgres"
  })
}
