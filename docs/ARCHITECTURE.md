# 🏗️ Архітектура проекту

## Огляд архітектури

Проект реалізує сучасну cloud-native архітектуру для розгортання Django додатків у AWS з використанням принципів Infrastructure as Code (IaC).

## Компоненти архітектури

### 1. Мережева інфраструктура (VPC)
```
VPC (10.0.0.0/16)
├── Публічні підмережі (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
│   ├── EKS Worker Nodes
│   ├── LoadBalancer
│   └── Internet Gateway
└── Приватні підмережі (10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24)
    └── RDS Database
```

**Характеристики:**
- Multi-AZ розгортання для високої доступності
- Публічні підмережі для EKS вузлів (dev середовище)
- Приватні підмережі для бази даних
- Відокремлені таблиці маршрутизації

### 2. Kubernetes кластер (EKS)
```
EKS Control Plane (AWS керований)
├── Worker Node Group
│   ├── t3.medium інстанси (2 вузли)
│   ├── Auto Scaling Group (1-3 вузли)
│   └── EBS CSI Driver
├── Add-ons
│   ├── CoreDNS
│   ├── kube-proxy
│   └── VPC CNI
└── IRSA (IAM Roles for Service Accounts)
```

**Особливості:**
- Керований control plane від AWS
- Автоматичне масштабування вузлів
- Інтеграція з AWS services через IRSA
- EBS CSI драйвер для persistent volumes

### 3. База даних (RDS PostgreSQL)
```
RDS PostgreSQL
├── Multi-AZ розгортання
├── Автоматичні backup-и
├── Performance Insights
├── Encryption at rest
└── Security Group (порт 5432 тільки з VPC)
```

**Налаштування:**
- PostgreSQL 15.8
- db.t3.micro instance
- 20GB gp3 storage з auto-scaling до 100GB
- 7 днів backup retention

### 4. Docker Registry (ECR)
```
Amazon ECR
├── Private repository
├── Image scanning
├── Lifecycle policies
└── Cross-region replication ready
```

**Функції:**
- Автоматичне сканування на вразливості
- Мutable теги для dev середовища
- Інтеграція з EKS через IAM

### 5. Django додаток
```
Django Application
├── Gunicorn WSGI server
├── WhiteNoise для статичних файлів
├── PostgreSQL driver
├── Health checks
└── Security middleware
```

**Стек:**
- Django 4.x
- Gunicorn
- WhiteNoise
- psycopg2
- Dockerfile optimized для production

## Kubernetes ресурси

### 1. Deployment
```yaml
Deployment
├── 2 репліки за замовчуванням
├── Rolling update strategy
├── Resource limits/requests
├── Security context (non-root)
└── Environment variables
```

### 2. Service
```yaml
LoadBalancer Service
├── AWS ELB integration
├── Порт 80 → 8000
├── Health checks
└── Multi-AZ distribution
```

### 3. Horizontal Pod Autoscaler
```yaml
HPA
├── Min replicas: 2
├── Max replicas: 6
├── Target CPU: 70%
└── Metrics server integration
```

### 4. ConfigMap та Secrets
```yaml
Configuration
├── ConfigMap: не-чутливі змінні
└── Secrets: паролі БД, API ключі
```

## Безпека

### 1. Мережева безпека
- Security Groups з принципом least privilege
- Приватні підмережі для бази даних
- Network ACLs на рівні підмереж

### 2. IAM безпека
- Окремі ролі для кожного сервісу
- IRSA для Kubernetes service accounts
- Minimal permissions principle

### 3. Pod безпека
- Non-root контейнери
- Security contexts
- Dropped capabilities
- ReadOnly root filesystem ready

### 4. Дані
- Encryption at rest для RDS
- Encryption in transit (TLS)
- Secrets у Kubernetes secrets (не в ConfigMaps)

## Моніторинг та логи

### 1. AWS рівень
- CloudWatch metrics
- RDS Performance Insights
- EKS cluster metrics

### 2. Kubernetes рівень
- kubectl logs
- Metrics server для HPA
- Ready для інтеграції з Prometheus

## Масштабування

### 1. Горизонтальне
- HPA для подів (2-6 реплік)
- EKS node group auto-scaling (1-3 вузли)
- RDS Multi-AZ для високої доступності

### 2. Вертикальне
- Adjustable resource requests/limits
- RDS instance class можна змінити
- Storage auto-scaling для RDS

## Disaster Recovery

### 1. Резервне копіювання
- RDS automated backups (7 днів)
- Point-in-time recovery
- ECR images зберігаються в регіоні

### 2. Високі доступність
- Multi-AZ RDS
- EKS розподілений по AZ
- Load Balancer з health checks

## CI/CD готовність

### 1. Automation scripts
- `build-and-push.sh` для Docker images
- `deploy-app.sh` для Kubernetes
- `setup-kubectl.sh` для конфігурації

### 2. GitOps ready
- Helm charts для версіонування
- Terraform modules для IaC
- Environment-based configuration

## Оптимізації для production

### Що потрібно додати:
1. **Secrets management**: AWS Secrets Manager або HashiCorp Vault
2. **Monitoring**: Prometheus + Grafana
3. **Logging**: ELK stack або AWS CloudWatch Logs
4. **Service Mesh**: Istio для мікросервісної архітектури
5. **GitOps**: ArgoCD або Flux
6. **Security scanning**: Falco, OPA Gatekeeper
7. **Network policies**: для мікросегментації

### Поточні обмеження:
- Dev конфігурація (EKS у публічних підмережах)
- Hardcoded secrets (слід використовувати AWS Secrets Manager)
- Відсутність monitoring/alerting
- Базове backup planning
