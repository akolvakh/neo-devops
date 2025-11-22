# 🛠️ Розв'язання проблем (Troubleshooting)

## Загальні проблеми та рішення

### 1. Terraform проблеми

#### Проблема: "Error: could not load plugin"
```bash
Error: could not load plugin
```

**Рішення:**
```bash
cd environments/dev
terraform init -upgrade
```

#### Проблема: "State file is locked"
```bash
Error: Error acquiring the state lock
```

**Рішення:**
```bash
# Перевірити активні операції
terraform force-unlock LOCK_ID

# Або очистити .terraform
rm -rf .terraform
terraform init
```

#### Проблема: "ECR repository already exists"
```bash
Error: Repository with name 'lesson-5-dev-ecr' already exists
```

**Рішення:**
```bash
# Імпортувати існуючий репозиторій
terraform import module.ecr.aws_ecr_repository.ecr lesson-5-dev-ecr
```

### 2. Docker проблеми

#### Проблема: "Docker daemon not running"
```bash
Cannot connect to the Docker daemon
```

**Рішення:**
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker
```

#### Проблема: "Architecture mismatch"
```bash
WARNING: The requested image's platform (linux/arm64) does not match
```

**Рішення:**
```bash
# Використовувати --platform у build-and-push.sh (вже додано)
docker build --platform linux/amd64 -t image:tag .
```

#### Проблема: "ECR login failed"
```bash
Error: Cannot perform an interactive login from a non TTY device
```

**Рішення:**
```bash
# Перевірити AWS креденшали
aws sts get-caller-identity

# Логін в ECR вручну
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ECR_URL
```

### 3. Kubernetes проблеми

#### Проблема: "kubectl: command not found"
```bash
bash: kubectl: command not found
```

**Рішення для macOS:**
```bash
brew install kubectl
```

**Рішення для Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

#### Проблема: "Unable to connect to the server"
```bash
Unable to connect to the server: dial tcp: lookup eks-cluster on 8.8.8.8:53
```

**Рішення:**
```bash
# Оновити kubeconfig
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-lesson-7

# Перевірити контекст
kubectl config current-context
```

#### Проблема: "ImagePullBackOff"
```yaml
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Warning  Failed     2m (x4 over 3m)  kubelet, node1     Failed to pull image
```

**Діагностика:**
```bash
# Перевірити поди
kubectl describe pod POD_NAME

# Перевірити образи в ECR
aws ecr describe-images --repository-name lesson-5-dev-ecr --region us-east-1
```

**Рішення:**
```bash
# Перебудувати та завантажити образ
./scripts/build-and-push.sh

# Оновити deployment
kubectl rollout restart deployment django-app-django-app
```

### 4. EKS проблеми

#### Проблема: "Nodes not ready"
```bash
NAME                                          STATUS     ROLES    AGE   VERSION
ip-10-0-1-100.us-east-1.compute.internal     NotReady   <none>   5m    v1.28.3-eks
```

**Діагностика:**
```bash
# Перевірити стан вузлів
kubectl get nodes -o wide

# Переглянути події
kubectl get events --sort-by=.metadata.creationTimestamp

# Перевірити системні поди
kubectl get pods -n kube-system
```

#### Проблема: "Insufficient capacity"
```bash
Warning  FailedScheduling  pod/django-app-xxx  0/2 nodes are available: 2 Insufficient cpu
```

**Рішення:**
```bash
# Зменшити ресурсні вимоги
kubectl patch deployment django-app-django-app -p='{"spec":{"template":{"spec":{"containers":[{"name":"django-app","resources":{"requests":{"cpu":"50m","memory":"128Mi"}}}]}}}}'

# Або збільшити кількість вузлів (в Terraform variables)
```

### 5. RDS проблеми

#### Проблема: "Database connection failed"
```bash
django.db.utils.OperationalError: could not connect to server
```

**Діагностика:**
```bash
# Перевірити RDS статус
aws rds describe-db-instances --region us-east-1

# Перевірити security groups
aws ec2 describe-security-groups --region us-east-1
```

**Рішення:**
```bash
# Перевірити connectivity з поду
kubectl exec -it POD_NAME -- nc -zv DB_HOSTNAME 5432

# Перевірити DATABASE_URL
kubectl exec -it POD_NAME -- env | grep DATABASE_URL
```

### 6. Django проблеми

#### Проблема: "Static files not served"
```bash
404 Not Found: /static/admin/css/base.css
```

**Рішення:**
```bash
# Перевірити WhiteNoise конфігурацію
kubectl exec -it POD_NAME -- python manage.py collectstatic --dry-run

# Перевірити settings
kubectl exec -it POD_NAME -- python manage.py diffsettings
```

#### Проблема: "Database migrations not applied"
```bash
You have 18 unapplied migration(s)
```

**Рішення:**
```bash
# Виконати міграції
kubectl exec -it POD_NAME -- python manage.py migrate

# Перевірити статус міграцій
kubectl exec -it POD_NAME -- python manage.py showmigrations
```

### 7. LoadBalancer проблеми

#### Проблема: "LoadBalancer stuck in pending"
```bash
EXTERNAL-IP   PORT(S)        AGE
<pending>     80:30123/TCP   5m
```

**Діагностика:**
```bash
# Перевірити сервіс
kubectl describe service django-app

# Перевірити AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer
```

**Рішення:**
```bash
# Перевірити IAM ролі для EKS
# Або змінити тип сервісу на NodePort для тестування
kubectl patch service django-app -p '{"spec":{"type":"NodePort"}}'
```

## Корисні команди для діагностики

### Загальна діагностика
```bash
# Статус всіх ресурсів
kubectl get all

# Події в кластері
kubectl get events --sort-by=.metadata.creationTimestamp

# Логи з усіх подів
kubectl logs -l app=django-app --all-containers=true

# Стан вузлів
kubectl top nodes
kubectl top pods
```

### Детальна діагностика поду
```bash
# Детальна інформація про под
kubectl describe pod POD_NAME

# Логи контейнера
kubectl logs POD_NAME -f

# Виконання команд в поді
kubectl exec -it POD_NAME -- /bin/bash

# Перевірка мережевої зв'язності
kubectl exec -it POD_NAME -- nc -zv DATABASE_HOST 5432
```

### AWS діагностика
```bash
# Статус EKS кластера
aws eks describe-cluster --name eks-cluster-lesson-7 --region us-east-1

# Статус RDS
aws rds describe-db-instances --region us-east-1

# ECR образи
aws ecr describe-images --repository-name lesson-5-dev-ecr --region us-east-1
```

## Моніторинг та метрики

### Основні метрики для відстеження
```bash
# Ресурсоспоживання подів
kubectl top pods

# Статус HPA
kubectl get hpa

# Стан deployment
kubectl get deployment django-app-django-app -o wide

# Стан сервісу
kubectl get service django-app -o wide
```

### Логи для аналізу
- **Pod logs**: `kubectl logs POD_NAME`
- **EKS cluster logs**: CloudWatch `/aws/eks/cluster-name/cluster`
- **RDS logs**: CloudWatch `/aws/rds/instance/database-name/error`

## Автоматизація troubleshooting

### Скрипт для швидкої діагностики
```bash
#!/bin/bash
echo "=== Kubernetes Resources ==="
kubectl get all

echo "=== Pod Status ==="
kubectl get pods -o wide

echo "=== Recent Events ==="
kubectl get events --sort-by=.metadata.creationTimestamp | tail -10

echo "=== Resource Usage ==="
kubectl top nodes
kubectl top pods
```

### Алерти та моніторинг
Рекомендовано налаштувати:
- CloudWatch alarms для RDS
- Kubernetes metrics server alerts
- Custom dashboards в Grafana

## Контакти для підтримки

При складних проблемах:
1. Перевірити логи та події
2. Зібрати діагностичну інформацію
3. Створити GitHub issue з деталями
4. Звернутися до AWS Support (для infrastructure issues)
