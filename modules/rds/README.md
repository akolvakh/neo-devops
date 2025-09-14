# 🗄️ Універсальний RDS Модуль

## 📋 Огляд

Цей модуль дозволяє створювати як звичайний RDS інстанс PostgreSQL, так і Aurora PostgreSQL кластер на основі змінної `use_aurora`.

## 🎯 Основні можливості

### ✅ Підтримувані конфігурації
- **Standard RDS**: Звичайний PostgreSQL інстанс
- **Aurora Cluster**: Aurora PostgreSQL з writer та reader інстансами

### 🔧 Автоматично створювані ресурси
- **DB Subnet Group**: для мережевої ізоляції
- **Security Group**: з правилами для PostgreSQL (порт 5432)
- **Parameter Groups**: з базовими налаштуваннями БД
- **Read Replicas**: для Aurora кластерів

### 🛡️ Налаштування безпеки
- Підтримка приватних та публічних підмереж
- Гнучкі налаштування Security Groups
- Шифрування сховища
- Multi-AZ deployment для високої доступності

## 📦 Використання

### Стандартний RDS
```hcl
module "rds" {
  source = "../../modules/rds"
  
  # Основна конфігурація
  name       = "my-postgres"
  use_aurora = false
  
  # Конфігурація БД
  db_name  = "myapp"
  username = "dbadmin"
  password = "SecurePassword123!"
  
  # Engine налаштування
  engine         = "postgres"
  engine_version = "14.19"
  instance_class = "db.t3.micro"
  
  # Мережа
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = "10.0.0.0/16"
  subnet_private_ids = module.vpc.private_subnets
  subnet_public_ids  = module.vpc.public_subnets
  publicly_accessible = false
  
  # Додаткові налаштування
  multi_az                = false
  backup_retention_period = 7
  
  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Aurora Cluster
```hcl
module "rds_aurora" {
  source = "../../modules/rds"
  
  # Основна конфігурація
  name       = "my-aurora"
  use_aurora = true
  
  # Конфігурація БД
  db_name  = "myapp"
  username = "dbadmin"
  password = "SecurePassword123!"
  
  # Aurora engine налаштування
  engine_cluster         = "aurora-postgresql"
  engine_version_cluster = "15.14"
  instance_class         = "db.t3.medium"
  
  # Мережа
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = "10.0.0.0/16"
  subnet_private_ids = module.vpc.private_subnets
  subnet_public_ids  = module.vpc.public_subnets
  publicly_accessible = false
  
  # Aurora специфічні налаштування
  aurora_replica_count    = 2
  backup_retention_period = 14
  
  # Parameter group
  parameter_group_family_aurora = "aurora-postgresql15"
  
  # Додаткові параметри БД
  parameters = {
    max_connections = "500"
    work_mem        = "8192"
    shared_preload_libraries = "pg_stat_statements"
  }
  
  tags = {
    Environment = "prod"
    Project     = "myapp"
  }
}
```

## 📋 Змінні модуля

### Обов'язкові змінні
| Назва | Тип | Опис |
|-------|-----|------|
| `name` | string | Назва інстансу або кластера |
| `db_name` | string | Назва бази даних |
| `username` | string | Майстер username |
| `password` | string | Майстер пароль (sensitive) |
| `vpc_id` | string | ID VPC |
| `vpc_cidr_block` | string | CIDR блок VPC |
| `subnet_private_ids` | list(string) | ID приватних підмереж |
| `subnet_public_ids` | list(string) | ID публічних підмереж |

### Опціональні змінні
| Назва | Тип | Default | Опис |
|-------|-----|---------|------|
| `use_aurora` | bool | false | Використовувати Aurora замість стандартного RDS |
| `engine` | string | "postgres" | Engine для стандартного RDS |
| `engine_version` | string | "14.19" | Версія engine для стандартного RDS |
| `engine_cluster` | string | "aurora-postgresql" | Engine для Aurora |
| `engine_version_cluster` | string | "15.14" | Версія engine для Aurora |
| `instance_class` | string | "db.t3.medium" | Клас інстансу |
| `allocated_storage` | number | 20 | Об'єм сховища (тільки для RDS) |
| `multi_az` | bool | false | Multi-AZ deployment |
| `publicly_accessible` | bool | false | Публічний доступ |
| `aurora_replica_count` | number | 1 | Кількість read replicas для Aurora |
| `backup_retention_period` | number | 7 | Період утримання backup (днів) |
| `parameters` | map(string) | {...} | Додаткові параметри БД |

## 📤 Outputs модуля

### Універсальні outputs
| Назва | Опис |
|-------|------|
| `rds_endpoint` | Endpoint для підключення |
| `rds_hostname` | Hostname БД |
| `rds_port` | Порт БД |
| `database_name` | Назва БД |
| `database_url` | Connection string (sensitive) |
| `security_group_id` | ID Security Group |

### Aurora специфічні outputs
| Назва | Опис |
|-------|------|
| `aurora_cluster_id` | ID Aurora кластера (null для RDS) |
| `aurora_reader_endpoint` | Reader endpoint (null для RDS) |

### Standard RDS специфічні outputs
| Назва | Опис |
|-------|------|
| `standard_rds_id` | ID RDS інстансу (null для Aurora) |

## 🏗️ Архітектура модуля

```
modules/rds/
├── variables.tf    # Оголошення змінних
├── shared.tf       # Спільні ресурси (subnet group, security group)
├── rds.tf          # Standard RDS ресурси
├── aurora.tf       # Aurora ресурси
├── outputs.tf      # Output values
└── README.md       # Ця документація
```

## 🔍 Приклади конфігурацій

### Development Environment
```hcl
use_aurora = false
instance_class = "db.t3.micro"
multi_az = false
backup_retention_period = 3
publicly_accessible = false
```

### Staging Environment
```hcl
use_aurora = false
instance_class = "db.t3.small"
multi_az = true
backup_retention_period = 7
publicly_accessible = false
```

### Production Environment (Aurora)
```hcl
use_aurora = true
instance_class = "db.r5.large"
aurora_replica_count = 3
backup_retention_period = 30
publicly_accessible = false
```

## 🛠️ Parameter Groups

Модуль автоматично створює parameter groups з базовими налаштуваннями:

### Стандартні параметри
```hcl
parameters = {
  max_connections = "200"
  log_statement   = "none"
  work_mem        = "4096"
}
```

### Рекомендовані параметри для продакшн
```hcl
parameters = {
  max_connections                = "500"
  shared_preload_libraries      = "pg_stat_statements"
  log_statement                 = "all"
  log_min_duration_statement    = "1000"
  work_mem                      = "16384"
  maintenance_work_mem          = "524288"
  effective_cache_size          = "1GB"
}
```

## 🔐 Безпека

### Рекомендації
1. **Ніколи не використовуйте публічний доступ** для продакшн БД
2. **Використовуйте AWS Secrets Manager** для паролів у продакшн
3. **Увімкніть шифрування** для всіх БД
4. **Налаштуйте VPC Flow Logs** для моніторингу мережевого трафіку

### Security Group Rules
Модуль автоматично створює Security Group з:
- **Ingress**: PostgreSQL (5432) з VPC CIDR або 0.0.0.0/0 (якщо публічний)
- **Egress**: Весь трафік дозволено

## 🔄 Міграція між типами БД

### З RDS на Aurora
1. Створіть snapshot поточної БД
2. Змініть `use_aurora = true`
3. Запустіть `terraform apply`
4. Відновіть дані з snapshot

### З Aurora на RDS
1. Створіть dump Aurora БД
2. Змініть `use_aurora = false`
3. Запустіть `terraform apply`
4. Відновіть дані з dump

## 🐛 Troubleshooting

### Часті проблеми

**Проблема**: Parameter group не оновлюється
```bash
# Рішення: Перезапустіть БД інстанс
aws rds reboot-db-instance --db-instance-identifier <instance-id>
```

**Проблема**: Не можу підключитися до БД
```bash
# Перевірте Security Group
aws ec2 describe-security-groups --group-ids <sg-id>

# Перевірте subnet group
aws rds describe-db-subnet-groups --db-subnet-group-name <name>
```

**Проблема**: Aurora replica не створюється
```bash
# Перевірте статус кластера
aws rds describe-db-clusters --db-cluster-identifier <cluster-id>
```

## 📊 Моніторинг

### CloudWatch Metrics
- **DatabaseConnections**: Кількість з'єднань
- **CPUUtilization**: Використання CPU
- **DatabaseSize**: Розмір БД
- **ReadLatency/WriteLatency**: Затримки читання/запису

### Performance Insights
Модуль автоматично увімкнює Performance Insights для детального моніторингу запитів.

## 📈 Рекомендації по продуктивності

### Standard RDS
- Використовуйте **gp3** storage для кращої продуктивності
- Налаштуйте **Multi-AZ** для високої доступності
- Увімкніть **automated backups**

### Aurora
- Використовуйте **read replicas** для читання
- Налаштуйте **Aurora Auto Scaling**
- Увімкніть **Aurora Serverless** для змінних навантажень

## 🧪 Тестування модуля

```bash
# Ініціалізація
terraform init

# Валідація
terraform validate

# План
terraform plan -var-file="terraform.tfvars"

# Застосування
terraform apply -var-file="terraform.tfvars"

# Перевірка підключення
psql "postgresql://username:password@hostname:5432/dbname"
```

---

**💡 Tip**: Завжди тестуйте модуль в dev середовищі перед використанням у продакшн!
