# 🚀 Керівництво з розгортання CI/CD Pipeline

## 📋 Огляд архітектури

Цей проєкт створює повну інфраструктуру для CI/CD з наступними компонентами:

```mermaid
graph TB
    A[GitHub Repository] --> B[Jenkins CI]
    B --> C[Kaniko Build]
    C --> D[Amazon ECR]
    D --> E[ArgoCD GitOps]
    E --> F[EKS Cluster]
    F --> G[Django Application]
    F --> H[PostgreSQL RDS]
```

## 🛠️ Компоненти інфраструктури

### AWS Ресурси
- **VPC**: Мережева інфраструктура з публічними та приватними підмережами
- **EKS**: Керований Kubernetes кластер
- **RDS PostgreSQL**: Керована база даних
- **ECR**: Приватний реєстр Docker образів
- **IAM**: Ролі та політики безпеки

### CI/CD Інструменти
- **Jenkins**: CI сервер з Kaniko для збірки образів
- **ArgoCD**: GitOps контролер для автоматичного деплою
- **Helm**: Пакетний менеджер для Kubernetes

### Додаткові сервіси
- **Load Balancers**: Для Jenkins, ArgoCD та Django застосунку
- **Persistent Volumes**: Для Jenkins workspace
- **Kubernetes Secrets**: Для безпечного зберігання паролів

## 📝 Передумови

### Обов'язкові інструменти
```bash
# AWS CLI
aws --version

# Terraform  
terraform version

# kubectl
kubectl version --client

# Helm (опціонально)
helm version
```

### AWS Налаштування
```bash
# Налаштування AWS CLI
aws configure set aws_access_key_id YOUR_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_SECRET_KEY
aws configure set default.region us-east-1
aws configure set default.output json

# Перевірка доступу
aws sts get-caller-identity
```

## 🚀 Покроковий деплой

### Крок 1: Клонування репозиторію
```bash
git clone <your-repository>
cd devops/akolvakh/l-9/environments/dev
```

### Крок 2: Конфігурація змінних
Створіть або відредагуйте `terraform.tfvars`:
```hcl
# ======================
# НАЛАШТУВАННЯ ПРОЄКТУ  
# ======================
project_name = "lesson-5"
environment  = "dev"
owner        = "your-username"

# ======================
# AWS НАЛАШТУВАННЯ
# ======================
aws_region = "us-east-1"

# ======================
# GITHUB ІНТЕГРАЦІЯ
# ======================
github_user     = "your-github-username"
github_pat      = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
github_repo_url = "https://github.com/your-username/your-repo.git"

# ======================
# БАЗА ДАНИХ
# ======================
db_name     = "djangodb"
db_user     = "dbadmin"  
db_password = "YourSecurePassword123!"
```

### Крок 3: Розгортання інфраструктури
```bash
# Ініціалізація Terraform
terraform init

# Планування змін
terraform plan -var-file="terraform.tfvars"

# Застосування конфігурації
terraform apply -var-file="terraform.tfvars" -auto-approve
```

### Крок 4: Конфігурація kubectl
```bash
# Оновлення kubeconfig
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-lesson-7

# Перевірка підключення
kubectl get nodes
kubectl get pods --all-namespaces
```

## 🔍 Перевірка розгортання

### Jenkins
```bash
# URL та credentials
echo "Jenkins URL: http://$(kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Username: admin"
echo "Password: admin123"

# Перевірка статусу
kubectl get pods -n jenkins
kubectl logs jenkins-0 -n jenkins
```

### ArgoCD
```bash
# URL та credentials
echo "ArgoCD URL: http://$(kubectl get svc argo-cd-argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Username: admin"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

# Перевірка статусу
kubectl get pods -n argocd
kubectl get applications -n argocd
```

### Django Application
```bash
# URL застосунку
echo "Django App: http://$(kubectl get svc example-app-django-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

# Перевірка статусу
kubectl get pods -l app.kubernetes.io/name=django-app
kubectl get svc example-app-django-app
```

## 🔄 Використання CI/CD

### Запуск Jenkins Pipeline
1. Відкрийте Jenkins UI
2. Знайдіть job `goit-django-docker`
3. Натисніть "Build Now"
4. Слідкуйте за логами виконання

### Моніторинг ArgoCD
1. Відкрийте ArgoCD UI
2. Перевірте статус `example-app`
3. Спостерігайте за синхронізацією

## 🐛 Troubleshooting

### Проблеми з Jenkins
```bash
# Діагностика Jenkins
kubectl describe pod jenkins-0 -n jenkins
kubectl get events -n jenkins --sort-by='.lastTimestamp'

# Перезапуск Jenkins
kubectl delete pod jenkins-0 -n jenkins
```

### Проблеми з ArgoCD
```bash
# Діагностика ArgoCD
kubectl describe application example-app -n argocd
kubectl logs deployment/argo-cd-argocd-server -n argocd

# Принудова синхронізація
kubectl patch application example-app -n argocd -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}' --type merge
```

### Проблеми з мережею
```bash
# Перевірка Load Balancers
kubectl get svc --all-namespaces | grep LoadBalancer

# Перевірка Security Groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=*eks*"
```

## 🧹 Очищення ресурсів

### Часткове очищення
```bash
# Видалення застосунків
kubectl delete application example-app -n argocd
kubectl delete all --all -n default
```

### Повне очищення
```bash
# УВАГА: Це видалить всі ресурси!
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

## 📊 Моніторинг та логи

### Корисні команди
```bash
# Загальний статус кластеру
kubectl get nodes -o wide
kubectl top nodes

# Статус всіх подів
kubectl get pods --all-namespaces -o wide

# Логи Jenkins
kubectl logs jenkins-0 -n jenkins -f

# Логи ArgoCD
kubectl logs deployment/argo-cd-argocd-server -n argocd -f

# Логи Django
kubectl logs deployment/example-app-django-app -f
```

### Events та діагностика
```bash
# Системні події
kubectl get events --sort-by=.metadata.creationTimestamp

# Опис ресурсів
kubectl describe pod <pod-name>
kubectl describe svc <service-name>
```

## 🔐 Безпека

### Секрети та облікові дані
- GitHub PAT зберігається як Kubernetes Secret
- Database credentials передаються через environment variables
- IAM ролі мають мінімальні необхідні привілеї

### Рекомендації для продакшн
- Використовувати AWS Secrets Manager
- Налаштувати HTTPS для всіх сервісів
- Увімкнути Pod Security Standards
- Налаштувати Network Policies

## 📚 Корисні посилання

### Документація
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Jenkins on Kubernetes](https://www.jenkins.io/doc/book/installing/kubernetes/)
- [ArgoCD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)

### Додаткові ресурси
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [GitOps Principles](https://opengitops.dev/)
- [CI/CD Best Practices](https://docs.gitlab.com/ee/ci/pipelines/pipeline_efficiency.html)
