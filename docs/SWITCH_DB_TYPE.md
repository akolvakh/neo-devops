# 🚀 Переключення між Aurora та Standard RDS

## Щоб використати Standard RDS
```bash
# В terraform.tfvars встановіть:
use_aurora = false
instance_class = "db.t3.micro"  # для dev
engine_version = "14.19"
parameter_group_family_rds = "postgres14"

# Запустіть:
terraform plan
terraform apply
```

## Щоб використати Aurora Cluster
```bash
# В terraform.tfvars встановіть:
use_aurora = true
instance_class = "db.t3.medium"  # Aurora потребує мінімум t3.medium
engine_version_cluster = "15.14"
parameter_group_family_aurora = "aurora-postgresql15" 
aurora_replica_count = 1

# Запустіть:
terraform plan
terraform apply
```

## Тестування підключення

### Standard RDS
```bash
# Отримайте endpoint з outputs
terraform output rds_endpoint

# Підключення
psql "postgresql://dbadmin:TempPassword123!@<rds-endpoint>:5432/djangodb"
```

### Aurora Cluster
```bash
# Writer endpoint
terraform output rds_endpoint

# Reader endpoint  
terraform output aurora_reader_endpoint

# Підключення до writer
psql "postgresql://dbadmin:TempPassword123!@<writer-endpoint>:5432/djangodb"

# Підключення до reader (для читання)
psql "postgresql://dbadmin:TempPassword123!@<reader-endpoint>:5432/djangodb"
```

## Моніторинг

### CloudWatch Metrics
```bash
# RDS Metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=rds-cluster \
  --start-time 2025-09-14T00:00:00Z \
  --end-time 2025-09-14T23:59:59Z \
  --period 3600 \
  --statistics Average

# Aurora Metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBClusterIdentifier,Value=rds-cluster-cluster \
  --start-time 2025-09-14T00:00:00Z \
  --end-time 2025-09-14T23:59:59Z \
  --period 3600 \
  --statistics Average
```

## Backup і Restore

### Manual Snapshot
```bash
# Standard RDS
aws rds create-db-snapshot \
  --db-instance-identifier rds-cluster \
  --db-snapshot-identifier rds-cluster-manual-$(date +%Y%m%d)

# Aurora
aws rds create-db-cluster-snapshot \
  --db-cluster-identifier rds-cluster-cluster \
  --db-cluster-snapshot-identifier aurora-manual-$(date +%Y%m%d)
```

## Performance Testing

### Basic Load Test
```bash
# Встановіть pgbench
# Ubuntu/Debian: sudo apt install postgresql-contrib
# macOS: brew install postgresql

# Ініціалізація тестових даних
pgbench -h <endpoint> -U dbadmin -d djangodb -i -s 10

# Тест на 5 хвилин з 10 з'єднаннями
pgbench -h <endpoint> -U dbadmin -d djangodb -c 10 -T 300

# Тест read-only для Aurora reader
pgbench -h <reader-endpoint> -U dbadmin -d djangodb -c 10 -T 300 -S
```
