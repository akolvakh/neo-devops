# 🚀 Швидкий старт

Цей файл містить мінімальний набір команд для швидкого розгортання проекту.

## Передумови ✅

Переконайтеся, що встановлені:
- ✅ AWS CLI (налаштований)
- ✅ Terraform >= 1.0
- ✅ Docker
- ✅ kubectl
- ✅ Helm >= 3.8

## Крок за кроком 📋

### 1. Розгортання інфраструктури
```bash
# Перейти в директорію Terraform
cd environments/dev

# Ініціалізувати Terraform
terraform init

# Переглянути план
terraform plan

# Застосувати конфігурацію
terraform apply

# Повернутися в корінь проекту
cd ../..
```

### 2. Налаштування kubectl
```bash
./scripts/setup-kubectl.sh
```

### 3. Збірка та публікація Docker образу
```bash
# Збірка з версією за замовчуванням (latest)
./scripts/build-and-push.sh

# Або з конкретною версією
./scripts/build-and-push.sh v1.4
```

### 4. Розгортання додатку
```bash
./scripts/deploy-app.sh
```

### 5. Створення адміністратора Django
```bash
# Отримати назву поду
kubectl get pods

# Створити суперкористувача (замініть POD_NAME на реальну назву)
kubectl exec -it POD_NAME -- python manage.py createsuperuser
```

## Перевірка стану 🔍

```bash
# Перевірити поди
kubectl get pods

# Перевірити сервіси
kubectl get svc

# Отримати URL додатку
kubectl get svc django-app

# Перевірити логи
kubectl logs -f POD_NAME
```

## Очищення ресурсів 🧹

```bash
# Видалити Kubernetes ресурси
helm uninstall django-app

# Видалити AWS інфраструктуру
cd environments/dev
terraform destroy
cd ../..
```

## Швидкі команди 💡

```bash
# Перезапустити deployment
kubectl rollout restart deployment django-app-django-app

# Масштабувати вручну
kubectl scale deployment django-app-django-app --replicas=4

# Переглянути всі ресурси
kubectl get all

# Підключитися до поду
kubectl exec -it POD_NAME -- /bin/bash

# Переспрямування портів для локального доступу
kubectl port-forward service/django-app 8080:80
```

## Важливі URL 🔗

- **Django додаток**: `http://LOADBALANCER_URL/`
- **Django admin**: `http://LOADBALANCER_URL/admin/`

URL LoadBalancer можна отримати командою:
```bash
kubectl get svc django-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```
