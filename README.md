# 🗄️ Урок 10: Універсальний RDS модуль - Aurora та Standard RDS

## 📋 Огляд проєкту

Цей проєкт розширює CI/CD pipeline з уроку 9, додаючи **універсальний RDS модуль**, який може створювати як звичайні RDS інстанси, так і Aurora кластери залежно від конфігурації.

## 🎯 Завдання уроку

Реалізувати універсальний модуль RDS, який:

1. ✅ **Підіймає Aurora Cluster або звичайну RDS instance** на основі значення `use_aurora`
2. ✅ **Автоматично створює всі необхідні ресурси:**
   - DB Subnet Group
   - Security Group
   - Parameter Group для обраного типу БД
3. ✅ **Працює з мінімальними змінами змінних** і підтримує багаторазове використання

## 🏗️ Архітектура рішення

```mermaid
graph TB
    A[terraform.tfvars] -->|use_aurora = true/false| B[RDS Module]
    B -->|use_aurora = false| C[Standard RDS]
    B -->|use_aurora = true| D[Aurora Cluster]
    
    C --> E[aws_db_instance]
    C --> F[aws_db_parameter_group - postgres14]
    
    D --> G[aws_rds_cluster]
    D --> H[aws_rds_cluster_instance - Writer]
    D --> I[aws_rds_cluster_instance - Reader]
    D --> J[aws_rds_cluster_parameter_group - aurora-postgresql15]
    
    B --> K[Shared Resources]
    K --> L[aws_db_subnet_group]
    K --> M[aws_security_group]
    
    style B fill:#e1f5fe
    style C fill:#c8e6c9
    style D fill:#fff3e0
```

## 📦 Структура модуля RDS

```
modules/rds/
├── variables.tf      # Змінні модуля
├── shared.tf         # Спільні ресурси (subnet group, security group)
├── rds.tf           # Standard RDS ресурси
├── aurora.tf        # Aurora ресурси  
├── outputs.tf       # Виходи модуля
└── README.md        # Документація модуля
```

## 🔧 Функціонал модуля

### Standard RDS (use_aurora = false)
- **aws_db_instance** - PostgreSQL інстанс
- **aws_db_parameter_group** - з postgres14 family
- **Налаштування**: max_connections, log_statement, work_mem

### Aurora Cluster (use_aurora = true)  
- **aws_rds_cluster** - Aurora PostgreSQL кластер
- **aws_rds_cluster_instance** - Writer інстанс
- **aws_rds_cluster_instance** - Reader replica(s)
- **aws_rds_cluster_parameter_group** - з aurora-postgresql15 family

### Спільні ресурси (завжди створюються)
- **aws_db_subnet_group** - для мережевої ізоляції
- **aws_security_group** - з правилами для PostgreSQL (порт 5432)

## 🚀 Швидкий старт

### 1. Клонування проєкту
```bash
cd /Users/anton/Desktop/goit/devops/akolvakh/l-10/environments/dev
```

### 2. Налаштування terraform.tfvars
```hcl
# Для Standard RDS
use_aurora = false
name = "lesson-10-rds"
db_name = "djangodb"
username = "dbadmin" 
password = "TempPassword123!"
instance_class = "db.t3.micro"

# Для Aurora Cluster
use_aurora = true
name = "lesson-10-aurora"
instance_class = "db.t3.medium"  # Aurora потребує мінімум t3.medium
aurora_replica_count = 1
```

### 3. Розгортання
```bash
terraform init
terraform validate
terraform plan -var-file="../../terraform.tfvars"
terraform apply -var-file="../../terraform.tfvars"
```

## 📊 Тестування конфігурацій

### Тест 1: Standard RDS
```bash
# terraform.tfvars
use_aurora = false
instance_class = "db.t3.micro"

terraform apply
```

**Результат:**
- ✅ Створюється 1 RDS інстанс
- ✅ Parameter group postgres14
- ✅ Один endpoint для читання і запису

### Тест 2: Aurora Cluster
```bash
# terraform.tfvars  
use_aurora = true
instance_class = "db.t3.medium"
aurora_replica_count = 2

terraform apply
```

**Результат:**
- ✅ Створюється Aurora кластер
- ✅ 1 Writer інстанс + 2 Reader replica
- ✅ Parameter group aurora-postgresql15  
- ✅ Окремі endpoints для читання і запису

## 🔍 Outputs модуля

### Універсальні outputs (працюють для обох типів)
```hcl
output "rds_endpoint" {
  description = "Endpoint для підключення"
  value = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}

output "database_url" {
  description = "Connection string"
  value = "postgresql://username:password@endpoint:port/dbname"
  sensitive = true
}
```

### Aurora специфічні outputs
```hcl
output "aurora_reader_endpoint" {
  description = "Reader endpoint (null для standard RDS)"
  value = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}
```

## 📈 Моніторинг та метрики

### CloudWatch Metrics
```bash
# Standard RDS
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=lesson-10-rds

# Aurora Cluster
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \  
  --metric-name DatabaseConnections \
  --dimensions Name=DBClusterIdentifier,Value=lesson-10-rds-cluster
```

### Performance Insights
Модуль автоматично увімкнює Performance Insights для детального аналізу запитів.

## 🔄 Переключення між типами БД

### З Standard RDS на Aurora
```bash
# 1. Створіть snapshot поточної БД
aws rds create-db-snapshot \
  --db-instance-identifier lesson-10-rds \
  --db-snapshot-identifier migration-to-aurora

# 2. Змініть конфігурацію
use_aurora = true
instance_class = "db.t3.medium"

# 3. Застосуйте зміни
terraform apply

# 4. Відновіть дані з snapshot (вручну через AWS Console)
```

### З Aurora на Standard RDS
```bash
# 1. Створіть cluster snapshot
aws rds create-db-cluster-snapshot \
  --db-cluster-identifier lesson-10-rds-cluster \
  --db-cluster-snapshot-identifier migration-to-rds

# 2. Змініть конфігурацію  
use_aurora = false
instance_class = "db.t3.micro"

# 3. Застосуйте зміни
terraform apply
```

## 💰 Вартість та рекомендації

### Development Environment
```hcl
# Мінімальна вартість
use_aurora = false
instance_class = "db.t3.micro"  # ~$12/місяць
multi_az = false
backup_retention_period = 3
```

### Production Environment  
```hcl
# Висока доступність та продуктивність
use_aurora = true
instance_class = "db.r6g.large"  # ~$150/місяць + replica
aurora_replica_count = 3
backup_retention_period = 30
```

## 🛡️ Безпека

### Рекомендації
- ✅ Використовуйте приватні підмережі (`publicly_accessible = false`)
- ✅ Налаштуйте Security Groups з мінімальними правами
- ✅ Увімкніть шифрування storage
- ✅ Використовуйте AWS Secrets Manager для паролів у продакшн

### Security Group Rules
```hcl
# Автоматично створюється модулем
ingress {
  from_port   = 5432
  to_port     = 5432  
  protocol    = "tcp"
  cidr_blocks = [var.vpc_cidr_block]  # Тільки з VPC
}
```

## 📚 Корисні команди

### Підключення до БД
```bash
# Standard RDS
psql "postgresql://dbadmin:password@$(terraform output -raw rds_endpoint)/djangodb"

# Aurora Writer  
psql "postgresql://dbadmin:password@$(terraform output -raw rds_endpoint)/djangodb"

# Aurora Reader
psql "postgresql://dbadmin:password@$(terraform output -raw aurora_reader_endpoint)/djangodb"
```

### Backup та Restore
```bash
# Manual snapshot (Standard RDS)
aws rds create-db-snapshot \
  --db-instance-identifier $(terraform output -raw standard_rds_id) \
  --db-snapshot-identifier manual-$(date +%Y%m%d)

# Manual snapshot (Aurora)  
aws rds create-db-cluster-snapshot \
  --db-cluster-identifier $(terraform output -raw aurora_cluster_id) \
  --db-cluster-snapshot-identifier aurora-$(date +%Y%m%d)
```

### Performance тестування  
```bash
# Встановлення pgbench
brew install postgresql  # macOS
sudo apt install postgresql-contrib  # Ubuntu

# Ініціалізація тестових даних
pgbench -h $(terraform output -raw rds_hostname) -U dbadmin -d djangodb -i -s 10

# Load test  
pgbench -h $(terraform output -raw rds_hostname) -U dbadmin -d djangodb -c 10 -T 300
```

## 🧪 Тестові сценарії

### Сценарій 1: Створення Standard RDS
```bash
use_aurora = false
terraform apply
# Очікуємо: 1 RDS інстанс + parameter group postgres14
```

### Сценарій 2: Міграція на Aurora
```bash  
use_aurora = true
terraform apply
# Очікуємо: Aurora кластер + writer + reader + parameter group aurora-postgresql15
```

### Сценарій 3: Масштабування Aurora
```bash
aurora_replica_count = 3
terraform apply  
# Очікуємо: 1 writer + 3 readers
```

## 🐛 Troubleshooting

### Проблема: Parameter group не застосовується
```bash
# Перезапустіть БД інстанс
aws rds reboot-db-instance --db-instance-identifier <instance-id>

# Для Aurora
aws rds failover-db-cluster --db-cluster-identifier <cluster-id>
```

### Проблема: Не вдається підключитися
```bash
# Перевірте Security Group
aws ec2 describe-security-groups --group-ids $(terraform output -raw security_group_id)

# Перевірте endpoint
terraform output rds_endpoint
```

### Проблема: Aurora replica не створюється
```bash
# Перевірте статус кластера
aws rds describe-db-clusters --db-cluster-identifier $(terraform output -raw aurora_cluster_id)

# Логи CloudTrail
aws logs describe-log-groups --log-group-name-prefix /aws/rds
```
