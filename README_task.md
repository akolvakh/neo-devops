# Домашнє завдання до теми «IaC (Terraform)»

## Опис завдання


Ваше домашнє завдання полягає у створенні Terraform-структури для інфраструктури на AWS у новій директорії `lesson-5`.

Вам потрібно налаштувати:

    1. Синхронізацію стейт-файлів у S3 з використанням DynamoDB для блокування.
    2. Мережеву інфраструктуру (VPC) з публічними та приватними підмережами.
    3. ECR (Elastic Container Registry) для зберігання Docker-образів.

```
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальне виведення ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   └── ecr/                 # Модуль для ECR
│       ├── ecr.tf           # Створення ECR репозиторію
│       ├── variables.tf     # Змінні для ECR
│       └── outputs.tf       # Виведення URL репозиторію ECR
│
└── README.md                # Документація проєкту

```





## Кроки виконання завдання

1. Створіть основну структуру проєкту

    У кореневій папці `lesson-5` створіть файли:

    - `main.tf` — підключення модулів.
    - `backend.tf` — налаштування бекенду для збереження стейтів у S3.
    - `outputs.tf` — загальні вихідні дані з усіх модулів.

2. Налаштуйте S3 для стейтів і DynamoDB

    У модулі `s3-backend`:

    - Налаштуйте S3-бакет для стейт-файлів Terraform.
    - Увімкніть версіювання для збереження історії стейтів.
    - Налаштуйте таблицю DynamoDB для блокування стейтів.

    Виведення має відбуватись у `outputs.tf` URL S3-бакета та ім'я DynamoDB.

3. Побудуйте мережеву інфраструктуру (VPC)

    У модулі `vpc`:

    - Створіть VPC з CIDR блоком.
    - Додайте 3 публічні підмережі та 3 приватні підмережі.
    - Створіть Internet Gateway для публічних підмереж.
    - Створіть NAT Gateway для приватних підмереж.
    - Налаштуйте маршрутизацію через Route Tables.

4. Створіть репозиторій ECR

    У модулі `ecr`:

    - Створіть ECR-репозиторій з автоматичним скануванням образів.
    - Налаштуйте політику доступу для репозиторію.
    - Виведіть URL репозиторію через `outputs.tf`.

5. Підключіть усі модулі в `main.tf`

    ```
    # Підключаємо модуль S3 та DynamoDB
    module "s3_backend" {
    source      = "./modules/s3-backend"
    bucket_name = "ваше ім'я"
    table_name  = "terraform-locks"
    }

    # Підключаємо модуль VPC
    module "vpc" {
    source             = "./modules/vpc"
    vpc_cidr_block     = "10.0.0.0/16"
    public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
    vpc_name           = "lesson-5-vpc"
    }

    # Підключаємо модуль ECR
    module "ecr" {
    source      = "./modules/ecr"
    ecr_name    = "lesson-5-ecr"
    scan_on_push = true
    }
    ```


6. Налаштуйте бекенд для Terraform

    Створіть `backend.tf` для налаштування S3 як бекенду:

    ```
    terraform {
    backend "s3" {
        bucket         = "ваше ім'я"
        key            = "lesson-5/terraform.tfstate"
        region         = "us-west-2"
        dynamodb_table = "terraform-locks"
        encrypt        = true
    }
    }
    ```

7. Зробіть документацію проєкту в `README.md`


    У файлі README.md додайте:

    - Опис структури проєкту.
    - Команди для ініціалізації та запуску:
        ```
        terraform init
        terraform plan
        terraform apply
        terraform destroy
        ```
    - Пояснення кожного модуля: `s3-backend`, `vpc`, `ecr`.

8. Завантажте проєкт у репозиторій

    1. Створіть нову гілку `lesson-5`.

        ```
        git checkout -b lesson-5
        ```
    2. Додайте зміни в гілку.

        ```
        git add .
        git commit -m "Add Terraform modules for S3, VPC, and ECR"
        git push origin lesson-5
        ```