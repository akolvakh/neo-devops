# 🚀 CI/CD Pipeline з Jenkins та ArgoCD на AWS EKS

## 📋 Огляд проєкту

Цей проєкт демонструє повну реалізацію CI/CD пайплайну для Django-застосунку з використанням сучасних DevOps практик та інструментів:

- **Jenkins** - Continuous Integration з Kaniko builds (без Docker daemon)
- **ArgoCD** - GitOps Continuous Deployment
- **AWS EKS** - керований Kubernetes кластер
- **PostgreSQL RDS** - керована база даних
- **Amazon ECR** - приватний реєстр Docker образів
- **Terraform** - Infrastructure as Code

## 🏗️ Архітектура рішення

```
📱 GitHub (приватний репозиторій lesson-8-9)
        ↓
🔨 Jenkins Pipeline (Kaniko containerless builds)
        ↓
📦 Amazon ECR (реєстр Docker образів)
        ↓
🚀 ArgoCD (GitOps автоматичний деплой)
        ↓
☸️ AWS EKS Cluster (Django App + Load Balancer)
        ↓
🗄️ PostgreSQL RDS (керована база даних)
```

## 🛠️ Технологічний стек

### Infrastructure & Cloud
- **AWS**: EKS, RDS, ECR, VPC, IAM, Load Balancers
- **Terraform**: Infrastructure as Code з модульною архітектурою
- **Kubernetes**: Container orchestration з Helm charts

### CI/CD & DevOps
- **Jenkins**: Pipeline automation з Configuration as Code
- **Kaniko**: Containerless Docker image builds
- **ArgoCD**: GitOps continuous deployment
- **Helm**: Kubernetes package management

### Application & Database
- **Django**: Python web framework
- **PostgreSQL**: Реляційна база даних
- **Gunicorn**: WSGI HTTP сервер

## 📦 Компоненти інфраструктури

### 🌐 Мережева інфраструктура (VPC Module)
- VPC з CIDR 10.0.0.0/16
- 3 публічні підмережі (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
- 3 приватні підмережі (10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24)
- Internet Gateway для публічного доступу
- Route Tables для маршрутизації

### ☸️ Kubernetes кластер (EKS Module)
- EKS кластер з версією 1.24+
- Managed node groups з t3.medium інстансами
- Auto Scaling Groups (min: 1, desired: 2, max: 3)
- OIDC Provider для Service Account інтеграції
- EBS CSI Driver для Persistent Volumes

### 🗄️ База даних (RDS Module)
- PostgreSQL 13.7 з Multi-AZ deployment
- db.t3.micro для dev середовища
- Автоматичні бекапи та point-in-time recovery
- Encryption at rest та in transit
- Private subnet deployment

### 📦 Container Registry (ECR Module)
- Приватний ECR репозиторій
- Автоматичне сканування на вразливості
- Lifecycle policies для керування образами
- Cross-account access policies

### 🔨 Jenkins CI Server
- Helm chart deployment з custom values
- Kubernetes agents з Kaniko підтримкою
- Configuration as Code (JCasC)
- GitHub integration з Personal Access Token
- IAM ролі для ECR доступу

### 🚀 ArgoCD GitOps Controller
- ArgoCD server з UI dashboard
- Repository credentials для приватних репо
- Automated sync policies
- Self-healing конфігурація
- Multi-environment підтримка

## 🚀 Покрокова інструкція розгортання

### Передумови

**Необхідне програмне забезпечення:**
```bash
# AWS CLI (версія 2.x)
aws --version

# Terraform (версія >= 1.0)
terraform --version

# kubectl для керування Kubernetes
kubectl version --client

# Helm (опціонально)
helm version
```

**AWS налаштування:**
```bash
# Налаштування AWS профілю
aws configure

# Перевірка доступу
aws sts get-caller-identity
```

### Крок 1: Підготовка проєкту

```bash
# Клонування репозиторію
git clone <your-repository>
cd devops/akolvakh/l-9

# Перехід в dev середовище
cd environments/dev
```

### Крок 2: Конфігурація змінних

Відредагуйте файл `terraform.tfvars`:

```hcl
# ======================
# НАЛАШТУВАННЯ ПРОЄКТУ
# ======================
project_name = "lesson-5"
environment  = "dev"
owner        = "akolvakh"

# ======================
# AWS КОНФІГУРАЦІЯ
# ======================
aws_region = "us-east-1"

# ======================
# МЕРЕЖНІ НАЛАШТУВАННЯ
# ======================
vpc_cidr_block = "10.0.0.0/16"
subnet_count   = 3

# ======================
# GITHUB ІНТЕГРАЦІЯ
# ======================
github_user     = "your-github-username"
github_pat      = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
github_repo_url = "https://github.com/your-username/neo-devops.git"

# ======================
# БАЗА ДАНИХ
# ======================
db_name     = "djangodb"
db_user     = "dbadmin"
db_password = "SecurePassword123!"
```

### Крок 3: Розгортання інфраструктури

```bash
# Ініціалізація Terraform backend
terraform init

# Перегляд плану змін
terraform plan -var-file="terraform.tfvars"

# Застосування конфігурації
terraform apply -var-file="terraform.tfvars" -auto-approve
```

**⏱️ Час розгортання: ~15-20 хвилин**

### Крок 4: Налаштування kubectl

```bash
# Оновлення kubeconfig для EKS
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-lesson-7

# Перевірка підключення
kubectl get nodes
kubectl get pods --all-namespaces
```

### Крок 5: Отримання доступів до сервісів

```bash
# Jenkins URL та credentials
kubectl get svc jenkins -n jenkins
echo "Jenkins URL: http://$(kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Username: admin"
echo "Password: admin123"

# ArgoCD URL та credentials  
kubectl get svc argo-cd-argocd-server -n argocd
echo "ArgoCD URL: http://$(kubectl get svc argo-cd-argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Username: admin"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Django Application URL
kubectl get svc example-app-django-app -n default
echo "Django App: http://$(kubectl get svc example-app-django-app -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

## 🔄 Використання CI/CD Pipeline

### Jenkins Pipeline Процес

1. **Доступ до Jenkins:**
   - Відкрийте Jenkins UI за отриманим URL
   - Увійдіть з credentials: admin/admin123

2. **Запуск Pipeline:**
   - Знайдіть job `goit-django-docker`
   - Натисніть "Build Now"
   - Спостерігайте за логами виконання

3. **Етапи Pipeline:**
   ```groovy
   stage('Build & Push Docker Image') {
     // Клонування коду з GitHub (lesson-8-9 branch)
     // Збірка Docker образу з Kaniko
     // Push образу в Amazon ECR з тегом v1.0.${BUILD_NUMBER}
   }
   
   stage('Update Chart Tag in Git') {
     // Оновлення Helm chart values.yaml з новим тегом
     // Commit та push змін назад в GitHub
   }
   ```

### ArgoCD Sync Process

1. **Автоматична синхронізація:**
   - ArgoCD моніторить GitHub репозиторій кожні 3 хвилини
   - При виявленні змін автоматично синхронізує стан
   - Self-healing виправляє ручні зміни в кластері

2. **Ручна синхронізація:**
   - Відкрийте ArgoCD UI
   - Виберіть application `example-app`
   - Натисніть "Sync" для примусової синхронізації

## 📁 Детальна структура проєкту

```
l-9/                                    # Корінь проєкту
├── environments/dev/                   # Dev середовище
│   ├── backend.tf                     # S3 backend конфігурація
│   ├── main.tf                        # Головна Terraform конфігурація
│   ├── variables.tf                   # Оголошення змінних
│   ├── outputs.tf                     # Вихідні значення
│   └── terraform.tfvars              # Значення змінних (не в Git!)
├── modules/                           # Terraform модулі
│   ├── vpc/                          # Мережна інфраструктура
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/                          # Kubernetes кластер
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/                          # PostgreSQL база
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/                          # Docker реєстр
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── jenkins/                      # Jenkins CI
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── values.yaml              # Helm values
│   └── argo_cd/                     # ArgoCD GitOps
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── charts/                  # Helm chart
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
├── Jenkinsfile                       # Pipeline definition
├── README.md                         # Документація
└── pics/                            # Скріншоти
    ├── jenkins.png
    └── argocd.png
```

## 🔧 Детальна конфігурація компонентів

### Jenkins Configuration as Code (JCasC)

```yaml
# Автоматичне створення seed job
jobs:
  - script: |
      job('seed-job') {
        description('Генерація pipeline для Django проєкту')
        scm {
          git {
            remote {
              url('${github_repo_url}')
              credentials('github-token')
            }
            branches('*/lesson-8-9')
          }
        }
        steps {
          dsl {
            text('''
              pipelineJob("goit-django-docker") {
                definition {
                  cpsScm {
                    scm {
                      git {
                        remote {
                          url("${github_repo_url}")
                          credentials("github-token")
                        }
                        branches("*/lesson-8-9")
                      }
                    }
                  }
                }
              }
            ''')
          }
        }
      }

# Автоматичні credentials
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: github-token
              username: ${github_user}
              password: ${github_pat}
```

### ArgoCD Application Configuration

```yaml
applications:
  - name: example-app
    namespace: default
    project: default
    source:
      repoURL: ${github_repo_url}
      path: charts/django-app
      targetRevision: lesson-8-9
      helm:
        valueFiles:
          - values.yaml
    destination:
      server: https://kubernetes.default.svc
      namespace: default
    syncPolicy:
      automated:
        prune: true      # Видалення застарілих ресурсів
        selfHeal: true   # Автоматичне виправлення змін
```

### Kubernetes Resources

**Автоматично створювані ресурси:**
```bash
# Namespaces
kubectl get ns
# jenkins, argocd, default

# Service Accounts
kubectl get sa --all-namespaces
# jenkins-sa з ECR доступом

# Secrets
kubectl get secrets --all-namespaces
# GitHub credentials, database connection, ArgoCD repos

# Persistent Volumes
kubectl get pv
# Jenkins workspace, ArgoCD data

# LoadBalancer Services
kubectl get svc --all-namespaces | grep LoadBalancer
# Jenkins, ArgoCD, Django App
```

## 🛡️ Безпека та найкращі практики

### Управління секретами

**Terraform managed secrets:**
```hcl
# Database connection string
resource "kubernetes_secret" "django_app_secret" {
  data = {
    database-url = "postgresql://${var.db_user}:${var.db_password}@${module.rds.db_instance_hostname}:5432/${var.db_name}"
  }
}

# GitHub credentials for Jenkins
resource "kubernetes_secret" "jenkins_github_credentials" {
  data = {
    username = var.github_user
    password = var.github_pat
  }
}
```

### IAM Roles and Policies

**Jenkins Service Account:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
```

### Network Security

**Security Groups:**
- RDS: доступ тільки з EKS worker nodes
- EKS: контрольований inbound/outbound трафік
- LoadBalancer: HTTP/HTTPS тільки з інтернету

## 📊 Моніторинг та логування

### Доступні інтерфейси моніторингу

1. **Jenkins Dashboard:**
   - Build history та статистика
   - Console output для кожного build
   - Pipeline visualization
   - Agent status та utilization

2. **ArgoCD Dashboard:**
   - Application sync status
   - Git repository connectivity
   - Kubernetes resource health
   - Sync history та rollback

3. **Kubernetes Dashboard:**
   ```bash
   # Встановлення dashboard (опціонально)
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
   
   # Створення admin user
   kubectl create serviceaccount dashboard-admin-sa
   kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
   
   # Отримання токену
   kubectl describe secret $(kubectl get secrets | grep dashboard-admin-sa | cut -f1 -d ' ') | grep -E '^token'
   
   # Запуск proxy
   kubectl proxy
   ```

### Корисні команди для діагностики

```bash
# Загальний статус кластеру
kubectl get nodes -o wide
kubectl get pods --all-namespaces -o wide
kubectl top nodes
kubectl top pods --all-namespaces

# Jenkins специфічні команди
kubectl get pods -n jenkins
kubectl logs -n jenkins jenkins-0 -f
kubectl describe pod jenkins-0 -n jenkins

# ArgoCD специфічні команди
kubectl get applications -n argocd
kubectl describe application example-app -n argocd
kubectl logs -n argocd deployment/argo-cd-argocd-server -f

# Django application діагностика
kubectl get pods -l app.kubernetes.io/name=django-app
kubectl logs deployment/example-app-django-app -f
kubectl describe hpa example-app-django-app

# Database connectivity
kubectl run postgres-client --rm -i --tty --image postgres:13 -- bash
# Inside container: psql postgresql://dbadmin:password@hostname:5432/djangodb

# Events та troubleshooting
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe node <node-name>
```

## 🧪 Тестування pipeline

### End-to-End тест CI/CD

1. **Підготовка тестових змін:**
   ```bash
   # У вашому neo-devops репозиторії
   git checkout lesson-8-9
   
   # Внесіть зміни в Django код
   echo "# Test change" >> django/README.md
   git add django/README.md
   git commit -m "Test CI/CD pipeline"
   git push origin lesson-8-9
   ```

2. **Моніторинг Jenkins build:**
   - Відкрийте Jenkins UI
   - Job `goit-django-docker` повинен запуститися автоматично
   - Спостерігайте за етапами build та push

3. **Перевірка ECR:**
   ```bash
   # Перевірка нових образів в ECR
   aws ecr describe-images --repository-name lesson-5-dev-ecr --region us-east-1
   ```

4. **Моніторинг ArgoCD sync:**
   - Відкрийте ArgoCD UI
   - Application `example-app` повинна показати OutOfSync
   - Після автоматичної синхронізації статус зміниться на Synced

5. **Перевірка деплою:**
   ```bash
   # Новий образ в деплойменті
   kubectl describe deployment example-app-django-app
   
   # Rollout статус
   kubectl rollout status deployment/example-app-django-app
   
   # Поди з новим образом
   kubectl get pods -l app.kubernetes.io/name=django-app -o jsonpath='{.items[*].spec.containers[0].image}'
   ```

### Performance тестування

```bash
# Load testing з Apache Bench
DJANGO_URL=$(kubectl get svc example-app-django-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
ab -n 1000 -c 10 http://$DJANGO_URL/

# Horizontal Pod Autoscaler тестування
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Всередині pod: while true; do wget -q -O- http://example-app-django-app/; done

# Моніторинг HPA
kubectl get hpa -w
```

## 🐛 Troubleshooting Guide

### Проблеми з Jenkins

**Problem: Jenkins pod не запускається**
```bash
# Діагностика
kubectl describe pod jenkins-0 -n jenkins
kubectl get pvc -n jenkins

# Вирішення: перевірити storage class
kubectl get sc
kubectl describe sc ebs-sc

# Перезапуск Jenkins
kubectl rollout restart statefulset jenkins -n jenkins
```

**Problem: Jenkins не може підключитися до GitHub**
```bash
# Перевірити credentials
kubectl get secret jenkins-github-credentials -n jenkins -o yaml
echo "password" | base64 -d  # розшифрувати password

# Тестування з Jenkins pod
kubectl exec jenkins-0 -n jenkins -- curl -u username:token https://api.github.com/user
```

**Problem: Kaniko builds падають**
```bash
# Перевірити IAM роль
kubectl describe sa jenkins-sa -n jenkins
kubectl describe pod <kaniko-pod> -n jenkins

# Перевірити ECR доступ
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com
```

### Проблеми з ArgoCD

**Problem: Application в стані Unknown**
```bash
# Детальна діагностика
kubectl describe application example-app -n argocd

# Перевірити repository connection
kubectl logs deployment/argo-cd-argocd-repo-server -n argocd

# Принудова синхронізація
kubectl patch application example-app -n argocd -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}' --type merge
```

**Problem: ArgoCD не може знайти Helm chart**
```bash
# Перевірити правильність шляху
kubectl get application example-app -n argocd -o yaml | grep path

# Перевірити GitHub repository structure
# Переконайтеся, що шлях charts/django-app існує в lesson-8-9 branch
```

### Проблеми з Django Application

**Problem: Pods в стані CrashLoopBackOff**
```bash
# Діагностика
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous

# Перевірити database connection
kubectl get secret example-app-django-app-secret -o yaml
echo "database-url" | base64 -d

# Перевірити RDS доступність
kubectl run postgres-client --rm -i --tty --image postgres:13 -- bash
# psql "connection-string-here"
```

**Problem: LoadBalancer не отримує External IP**
```bash
# Перевірити AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer

# Перевірити service
kubectl describe svc example-app-django-app

# Альтернатива: NodePort для тестування
kubectl patch svc example-app-django-app -p '{"spec":{"type":"NodePort"}}'
```

### Проблеми з мережею та DNS

**Problem: Pods не можуть підключитися до RDS**
```bash
# Перевірити Security Groups
aws ec2 describe-security-groups --group-ids <rds-sg-id>

# Перевірити DNS resolution
kubectl run dnsutils --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 --rm -i --tty
# nslookup <rds-endpoint>
```

## 🔄 Lifecycle Management

### Оновлення компонентів

**Оновлення Terraform модулів:**
```bash
# Перевірити доступні оновлення
terraform plan -var-file="terraform.tfvars"

# Поетапне оновлення
terraform apply -target=module.eks -var-file="terraform.tfvars"
terraform apply -target=module.jenkins -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

**Оновлення Jenkins:**
```bash
# Оновити Helm chart version в jenkins/main.tf
terraform apply -target=module.jenkins

# Або через Helm напряму
helm upgrade jenkins jenkins/jenkins -n jenkins -f modules/jenkins/values.yaml
```

**Оновлення ArgoCD:**
```bash
# Оновити chart_version в terraform
terraform apply -target=module.argo_cd

# Перевірити статус
kubectl get pods -n argocd
```

### Backup та Recovery

**Jenkins Backup:**
```bash
# Backup Jenkins home
kubectl exec jenkins-0 -n jenkins -- tar czf - /var/jenkins_home | cat > jenkins-backup-$(date +%Y%m%d).tar.gz

# Restore
kubectl cp jenkins-backup.tar.gz jenkins/jenkins-0:/tmp/
kubectl exec jenkins-0 -n jenkins -- bash -c "cd / && tar xzf /tmp/jenkins-backup.tar.gz"
```

**ArgoCD Backup:**
```bash
# Backup ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Backup repositories
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o yaml > argocd-repos-backup.yaml
```

**Database Backup:**
```bash
# RDS automatic backups вже налаштовані
# Point-in-time recovery доступний
aws rds describe-db-instances --db-instance-identifier <db-identifier>

# Manual snapshot
aws rds create-db-snapshot --db-instance-identifier <db-identifier> --db-snapshot-identifier manual-snapshot-$(date +%Y%m%d)
```

## 📈 Масштабування та оптимізація

### Horizontal Pod Autoscaling

Django application вже налаштований з HPA:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: example-app-django-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: example-app-django-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Cluster Autoscaling

```bash
# Додати cluster autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Налаштувати для вашого кластеру
kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"cluster-autoscaler","command":["./cluster-autoscaler","--v=4","--stderrthreshold=info","--cloud-provider=aws","--skip-nodes-with-local-storage=false","--expander=least-waste","--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/eks-cluster-lesson-7"]}]}}}}'
```

### Resource Optimization

```bash
# Аналіз використання ресурсів
kubectl top nodes
kubectl top pods --all-namespaces

# Vertical Pod Autoscaler recommendations
kubectl describe vpa <vpa-name>

# Resource quotas для namespace
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: default
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
EOF
```

## 🌍 Multi-environment Setup

### Staging Environment

```bash
# Створити staging середовище
mkdir -p environments/staging
cp environments/dev/* environments/staging/

# Оновити terraform.tfvars для staging
sed -i 's/environment = "dev"/environment = "staging"/' environments/staging/terraform.tfvars
sed -i 's/lesson-5/lesson-5-staging/' environments/staging/terraform.tfvars

# Розгорнути staging
cd environments/staging
terraform init
terraform apply
```

### Production Considerations

```hcl
# environments/prod/terraform.tfvars
environment = "prod"

# Більші інстанси для production
instance_type = "t3.large"
desired_size  = 3
max_size      = 10
min_size      = 2

# Immutable ECR tags
ecr_image_tag_mutability = "IMMUTABLE"

# Multi-AZ database
db_instance_class = "db.t3.small"
multi_az         = true
backup_retention = 30

# Додаткові security groups
additional_security_groups = ["sg-prod-extra"]
```

## 🧹 Очищення ресурсів

### Часткове очищення

```bash
# Видалити тільки applications
kubectl delete application example-app -n argocd

# Видалити Jenkins jobs
kubectl exec jenkins-0 -n jenkins -- rm -rf /var/jenkins_home/jobs/*

# Очистити ECR images
aws ecr batch-delete-image --repository-name lesson-5-dev-ecr --image-ids imageTag=latest
```

### Повне очищення

```bash
cd environments/dev

# Видалити Kubernetes resources спершу
kubectl delete all --all -n default
kubectl delete all --all -n jenkins  
kubectl delete all --all -n argocd

# Видалити persistent volumes
kubectl delete pv --all

# Terraform destroy
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

**⚠️ УВАГА**: Це видалить ВСІ ресурси включно з базами даних та backup'ами!

### Cleanup для окремих модулів

```bash
# Видалити тільки Jenkins
terraform destroy -target=module.jenkins

# Видалити тільки ArgoCD  
terraform destroy -target=module.argo_cd

# Видалити тільки Django app
kubectl delete deployment example-app-django-app
kubectl delete svc example-app-django-app
kubectl delete secret example-app-django-app-secret
```

## 📚 Додаткова документація та ресурси

### Офіційна документація
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Jenkins on Kubernetes](https://www.jenkins.io/doc/book/installing/kubernetes/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kaniko Documentation](https://github.com/GoogleContainerTools/kaniko)

### Корисні посилання
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [GitOps Principles](https://opengitops.dev/)
- [12-Factor App Methodology](https://12factor.net/)
- [CNCF Landscape](https://landscape.cncf.io/)

### Спільнота та підтримка
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [Jenkins Community](https://www.jenkins.io/participate/)
- [ArgoCD Community](https://argoproj.github.io/community/)
- [AWS Containers Roadmap](https://github.com/aws/containers-roadmap)