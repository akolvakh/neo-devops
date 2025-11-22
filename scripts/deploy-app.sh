#!/bin/bash

# ==============================================
# РОЗГОРТАННЯ DJANGO ДОДАТКУ В KUBERNETES
# ==============================================

set -e

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Без кольору

print_status() {
    echo -e "${BLUE}[ІНФО]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[УСПІХ]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ПОПЕРЕДЖЕННЯ]${NC} $1"
}

print_error() {
    echo -e "${RED}[ПОМИЛКА]${NC} $1"
}

# Конфігурація
NAMESPACE=${NAMESPACE:-default}
RELEASE_NAME=${RELEASE_NAME:-django-app}
CHART_PATH="./charts/django-app"

print_status "Початок розгортання Django додатку в Kubernetes..."

# Перевірити, чи налаштований kubectl
if ! kubectl cluster-info > /dev/null 2>&1; then
    print_error "kubectl не налаштований або не підключений до кластера"
    print_error "Спочатку запустіть './scripts/setup-kubectl.sh'"
    exit 1
fi

print_success "kubectl налаштований і підключений"

# Перевірити, чи встановлений helm
if ! command -v helm &> /dev/null; then
    print_error "Helm не встановлений. Будь ласка, спочатку встановіть Helm."
    exit 1
fi

print_success "Helm доступний"

# Перевірити, чи існує директорія чарту
if [[ ! -d "$CHART_PATH" ]]; then
    print_error "Helm чарт не знайдено за адресою $CHART_PATH"
    exit 1
fi

# Отримати URL бази даних з Terraform
print_status "Отримання інформації про підключення до бази даних з Terraform..."
cd environments/dev
DB_HOSTNAME=$(terraform output -raw db_instance_hostname 2>/dev/null || echo "")
DB_PORT=$(terraform output -raw db_instance_port 2>/dev/null || echo "5432")
DB_NAME=$(terraform output -raw db_instance_name 2>/dev/null || echo "djangodb")

if [[ -z "$DB_HOSTNAME" ]]; then
    print_error "Не вдалося отримати хостнейм бази даних з Terraform outputs"
    print_error "Переконайтеся, що RDS успішно розгорнуто"
    exit 1
fi

cd ../..

# Створити URL бази даних
DATABASE_URL="postgres://dbadmin:TempPassword123!@${DB_HOSTNAME}:${DB_PORT}/${DB_NAME}"

print_success "Підключення до бази даних налаштовано"

# Отримати URL ECR репозиторію
print_status "Отримання URL ECR репозиторію..."
cd environments/dev
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")
cd ../..

if [[ -z "$ECR_URL" ]]; then
    print_error "Не вдалося отримати ECR URL з Terraform outputs"
    exit 1
fi

print_success "ECR репозиторій: $ECR_URL"

# Створити namespace якщо він не існує
if [[ "$NAMESPACE" != "default" ]]; then
    print_status "Створення namespace '$NAMESPACE' якщо він не існує..."
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
fi

# Створити секрет для URL бази даних
print_status "Створення Kubernetes секрету для бази даних..."
kubectl create secret generic django-secrets \
    --from-literal=database-url="$DATABASE_URL" \
    --namespace=$NAMESPACE \
    --dry-run=client -o yaml | kubectl apply -f -

print_success "Секрет створено/оновлено"

# Оновити values.yaml з поточним ECR URL (видалити префікс https://)
print_status "Оновлення Helm values з ECR URL..."
VALUES_FILE="$CHART_PATH/values.yaml"
cp $VALUES_FILE ${VALUES_FILE}.backup

# Очистити ECR URL (видалити префікс https:// якщо присутній)
ECR_REPO_CLEAN=$(echo $ECR_URL | sed 's|https://||')

# Оновити репозиторій образу в values.yaml
sed -i.tmp "s|repository: .*|repository: $ECR_REPO_CLEAN|g" $VALUES_FILE
rm ${VALUES_FILE}.tmp

print_success "Values оновлено"

# Розгорнути з Helm
print_status "Розгортання Django додатку з Helm..."
helm upgrade --install $RELEASE_NAME $CHART_PATH \
    --namespace=$NAMESPACE \
    --set image.repository=$ECR_REPO_CLEAN \
    --set image.tag=latest \
    --set config.DATABASE_URL="$DATABASE_URL" \
    --wait \
    --timeout=300s

if [[ $? -eq 0 ]]; then
    print_success "Django додаток успішно розгорнуто!"
else
    print_error "Розгортання не вдалося"
    exit 1
fi

# Показати статус розгортання
print_status "Перевірка статусу розгортання..."
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=django-app

# Отримати інформацію про сервіс
print_status "Отримання інформації про сервіс..."
kubectl get services -n $NAMESPACE -l app.kubernetes.io/name=django-app

# Показати логи з одного поду
print_status "Показ останніх логів з Django додатку..."
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=django-app -o jsonpath='{.items[0].metadata.name}')
if [[ -n "$POD_NAME" ]]; then
    print_status "Логи з поду $POD_NAME:"
    kubectl logs $POD_NAME -n $NAMESPACE --tail=20
else
    print_warning "Поди для Django додатку не знайдено"
fi

print_success "Розгортання завершено!"
print_status "Для доступу до вашого додатку:"
print_status "1. Перевірити LoadBalancer сервіс: kubectl get service $RELEASE_NAME -n $NAMESPACE"
print_status "2. Або переспрямувати порт: kubectl port-forward service/$RELEASE_NAME -n $NAMESPACE 8080:80"
print_status "3. Перевірити статус: kubectl get all -n $NAMESPACE"
