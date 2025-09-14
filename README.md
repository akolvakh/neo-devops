# AWS інфраструктура з Terraform

Цей проєкт створює базову AWS інфраструктуру за допомогою Terraform, включаючи VPC, S3 бакет для зберігання стану та ECR репозиторій.

## Огляд архітектури

Проєкт розгортає наступну інфраструктуру в AWS:

- **VPC** з публічними та приватними підмережами
- **S3 бакет** для зберігання стану Terraform
- **DynamoDB таблиця** для блокування стану
- **ECR репозиторій** для зберігання Docker образів
- **Internet Gateway** для доступу до інтернету
- **Route Tables** для маршрутизації мережевого трафіку

## Структура проєкту

```
l-5/
├── README.md              # Ця документація
├── backend.tf             # Конфігурація backend для Terraform
├── main.tf                # Основні ресурси та модулі
├── variables.tf           # Змінні проєкту
├── outputs.tf             # Виходи проєкту
└── modules/               # Terraform модулі
    ├── s3-backend/        # S3 бакет та DynamoDB для стану
    ├── vpc/               # VPC з підмережами та маршрутизацією
    └── ecr/               # ECR репозиторій
```

## Передумови

### Необхідне програмне забезпечення:
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) налаштований з відповідними правами
- AWS облікові дані з правами на створення:
  - VPC та мережеві ресурси
  - S3 бакети
  - DynamoDB таблиці
  - ECR репозиторії

### AWS права:
Ваш AWS користувач повинен мати наступні права:
- `AmazonVPCFullAccess`
- `AmazonS3FullAccess`
- `AmazonDynamoDBFullAccess`
- `AmazonEC2ContainerRegistryFullAccess`

## Швидкий старт

### 1. Налаштування AWS облікових даних

```bash
# Налаштуйте AWS CLI
aws configure

# Або експортуйте змінні оточення
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. Клонування та ініціалізація

```bash
# Перейдіть до папки проєкту
cd /path/to/goit/devops/akolvakh/l-5

# Ініціалізація Terraform
terraform init
```

### 3. Планування та застосування

```bash
# Перегляд плану змін
terraform plan

# Застосування змін
terraform apply
```

## Конфігурація

### Змінні проєкту

Файл `variables.tf` містить наступні налаштування:

| Змінна | Опис | За замовчуванням |
|--------|------|------------------|
| `aws_region` | AWS регіон | `us-east-1` |
| `bucket_name` | Назва S3 бакету для стану | `akolvakh-tfstate` |
| `ecr_name` | Назва ECR репозиторію | `akolvakh-ecr` |
| `dynamodb_table` | Назва DynamoDB таблиці | `terraform-locks` |
| `vpc_name` | Назва VPC | `akolvakh-vpc` |

### Мережева архітектура

VPC створюється з наступними параметрами:
- **CIDR блок**: `10.0.0.0/16`
- **Публічні підмережі**: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`
- **Приватні підмережі**: `10.0.4.0/24`, `10.0.5.0/24`, `10.0.6.0/24`
- **Зони доступності**: `us-east-1a`, `us-east-1b`, `us-east-1c`

### Налаштування для іншого регіону

Для зміни регіону:

1. Оновіть `backend.tf`:
```terraform
terraform {
  backend "s3" {
    bucket         = "devops-tfstate-akolvakh"
    key            = "lesson-5/terraform.tfstate"
    region         = "eu-west-1"  # Новий регіон
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

2. Оновіть зони доступності в `main.tf`:
```terraform
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
```

## Модулі

### 1. S3 Backend модуль (`modules/s3-backend/`)

Створює:
- S3 бакет з увімкненою версіонацією
- DynamoDB таблицю для блокування стану
- Налаштування шифрування

### 2. VPC модуль (`modules/vpc/`)

Створює:
- VPC з DNS підтримкою
- Публічні підмережі з автоматичним призначенням публічних IP
- Приватні підмережі
- Internet Gateway
- Route Tables та Routes

### 3. ECR модуль (`modules/ecr/`)

Створює:
- ECR репозиторій
- Налаштування сканування образів
- Політики життєвого циклу образів

## Команди Terraform

### Основні команди

```bash
# Ініціалізація проєкту
terraform init

# Валідація конфігурації
terraform validate

# Форматування коду
terraform fmt

# Планування змін
terraform plan

# Застосування змін
terraform apply

# Знищення інфраструктури
terraform destroy
```

### Робота зі змінними

```bash
# Використання файлу змінних
terraform apply -var-file="production.tfvars"

# Передача змінних через командний рядок
terraform apply -var="bucket_name=my-custom-bucket"

# Використання змінних оточення
export TF_VAR_bucket_name="my-custom-bucket"
terraform apply
```

### Робота зі станом

```bash
# Перегляд стану
terraform show

# Список ресурсів у стані
terraform state list

# Детальна інформація про ресурс
terraform state show aws_vpc.main

# Імпорт існуючого ресурсу
terraform import aws_vpc.main vpc-12345678
```

## Виходи (Outputs)

Після застосування конфігурації ви отримаєте:

- `s3_bucket_name` - Назва створеного S3 бакету
- `s3_bucket_url` - URL S3 бакету
- `vpc_id` - ID створеного VPC
- `public_subnet` - Список ID публічних підмереж
- `private_subnet` - Список ID приватних підмереж  
- `ecr_repo_url` - URL ECR репозиторію

### Перегляд виходів

```bash
# Всі виходи
terraform output

# Конкретний вихід
terraform output vpc_id

# Вихід у JSON форматі
terraform output -json
```


## Усунення проблем

### Поширені помилки

1. **Backend не ініціалізовано**:
```bash
Error: Backend initialization required
```
**Рішення**: Виконайте `terraform init`

2. **Недостатньо прав AWS**:
```bash
Error: UnauthorizedOperation
```
**Рішення**: Перевірте права AWS користувача

3. **Ресурс вже існує**:
```bash
Error: resource already exists
```
**Рішення**: Імпортуйте існуючий ресурс або змініть назву

4. **State locked**:
```bash
Error: Error acquiring the state lock
```
**Рішення**: 
```bash
terraform force-unlock LOCK_ID
```

### Відладка

```bash
# Увімкнути детальне логування
export TF_LOG=DEBUG
export TF_LOG_PATH="./terraform.log"
terraform apply

# Перевірка провайдера
terraform providers

# Валідація синтаксису
terraform validate
```

## Очищення ресурсів

### Безпечне видалення

```bash
# Перегляд ресурсів для видалення
terraform plan -destroy

# Видалення інфраструктури
terraform destroy

# Підтвердження видалення
# Type: yes
```

### Вибіркове видалення

```bash
# Видалення конкретного ресурсу
terraform destroy -target=aws_instance.example

# Видалення модуля
terraform destroy -target=module.vpc
```

## Додаткові ресурси

### Корисні посилання

- [Terraform документація](https://www.terraform.io/docs/)
- [AWS Provider документація](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform best practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Навчальні матеріали

- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [AWS Terraform Workshop](https://aws.amazon.com/getting-started/hands-on/deploy-infrastructure-terraform/)

## Внесок у розвиток

1. Створіть feature branch
2. Внесіть зміни
3. Протестуйте локально
4. Створіть Pull Request

## Ліцензія

Цей проєкт використовується для навчальних цілей.