#!/bin/bash

# ==============================================
# Скрипт збірки та завантаження Django Docker образу
# ==============================================

set -e  # Вийти при будь-якій помилці

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Без кольору

# Конфігурація
REGION="us-east-1"
IMAGE_TAG=${1:-"latest"}
DOCKERFILE_PATH="./django/Dockerfile"
BUILD_CONTEXT="./django"

# Отримати інформацію про ECR з Terraform outputs
echo -e "${YELLOW}Отримання інформації про ECR репозиторій з Terraform...${NC}"
if [ ! -f "./environments/dev/terraform.tfstate" ] && [ ! -f "./environments/dev/.terraform/terraform.tfstate" ]; then
    echo -e "${RED}❌ Стан Terraform не знайдено. Спочатку запустіть terraform apply.${NC}"
    exit 1
fi

cd environments/dev
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null) || {
    echo -e "${RED}❌ Не вдалося отримати ECR URL з Terraform outputs${NC}"
    echo -e "${YELLOW}Переконайтеся, що terraform apply було успішно виконано${NC}"
    exit 1
}
cd ../..

# Парсинг ECR URL для отримання реєстру та назви репозиторію
# Видалити префікс https:// якщо присутній
ECR_URL_CLEAN=$(echo $ECR_URL | sed 's|https://||')
ECR_REGISTRY=$(echo $ECR_URL_CLEAN | cut -d'/' -f1)
REPOSITORY_NAME=$(echo $ECR_URL_CLEAN | cut -d'/' -f2)

# Повна назва образу
FULL_IMAGE_NAME="${ECR_URL_CLEAN}:${IMAGE_TAG}"

echo -e "${BLUE}=== Збірка та завантаження Django Docker образу ===${NC}"
echo -e "${BLUE}Реєстр: ${ECR_REGISTRY}${NC}"
echo -e "${BLUE}Репозиторій: ${REPOSITORY_NAME}${NC}"
echo -e "${BLUE}Тег: ${IMAGE_TAG}${NC}"
echo -e "${BLUE}Повний образ: ${FULL_IMAGE_NAME}${NC}"
echo ""

# Перевірити, чи запущений Docker
echo -e "${YELLOW}Перевірка Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker не запущений. Будь ласка, запустіть Docker та спробуйте знову.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker запущений${NC}"

# Перевірити, чи існує Dockerfile
if [ ! -f "${DOCKERFILE_PATH}" ]; then
    echo -e "${RED}❌ Dockerfile не знайдено за адресою ${DOCKERFILE_PATH}${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dockerfile знайдено${NC}"

# Перевірити, чи існує Django додаток
if [ ! -d "${BUILD_CONTEXT}" ]; then
    echo -e "${RED}❌ Директорія Django додатку не знайдена за адресою ${BUILD_CONTEXT}${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Директорія Django додатку знайдена${NC}"

# Вхід в ECR
echo -e "${YELLOW}Вхід в Amazon ECR...${NC}"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Успішно увійшли в ECR${NC}"
else
    echo -e "${RED}❌ Не вдалося увійти в ECR${NC}"
    exit 1
fi

# Перевірити, чи існує ECR репозиторій
echo -e "${YELLOW}Перевірка існування ECR репозиторію...${NC}"
if aws ecr describe-repositories --region ${REGION} --repository-names ${REPOSITORY_NAME} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ECR репозиторій існує${NC}"
else
    echo -e "${RED}❌ ECR репозиторій '${REPOSITORY_NAME}' не існує${NC}"
    echo -e "${YELLOW}Будь ласка, спочатку створіть репозиторій або розгорніть інфраструктуру${NC}"
    exit 1
fi

# Збірка Docker образу для AMD64 архітектури
echo -e "${YELLOW}Збірка Docker образу для AMD64 архітектури...${NC}"
docker build --platform linux/amd64 -t ${FULL_IMAGE_NAME} -f ${DOCKERFILE_PATH} ${BUILD_CONTEXT}
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker образ успішно зібрано${NC}"
else
    echo -e "${RED}❌ Не вдалося зібрати Docker образ${NC}"
    exit 1
fi

# Створення додаткових тегів образу при необхідності
echo -e "${YELLOW}Тегування образу...${NC}"
docker tag ${FULL_IMAGE_NAME} ${ECR_URL_CLEAN}:latest
echo -e "${GREEN}✅ Образ позначено тегом${NC}"

# Завантаження образу в ECR
echo -e "${YELLOW}Завантаження образу в ECR...${NC}"
docker push ${ECR_URL_CLEAN}:${IMAGE_TAG}
docker push ${ECR_URL_CLEAN}:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Образ успішно завантажено${NC}"
else
    echo -e "${RED}❌ Не вдалося завантажити образ${NC}"
    exit 1
fi

# Показати деталі образу
echo ""
echo -e "${BLUE}=== Деталі образу ===${NC}"
echo -e "${BLUE}URI репозиторію: ${ECR_URL_CLEAN}${NC}"
echo -e "${GREEN}Тег образу: ${IMAGE_TAG}${NC}"
echo -e "${GREEN}Повний URI образу: ${FULL_IMAGE_NAME}${NC}"
echo ""

# Отримати деталі образу з ECR
echo -e "${YELLOW}Отримання інформації про образ з ECR...${NC}"
aws ecr describe-images --region ${REGION} --repository-name ${REPOSITORY_NAME} --image-ids imageTag=${IMAGE_TAG} --query 'imageDetails[0].{PushedAt:imagePushedAt,Size:imageSizeInBytes}' --output table

echo ""
echo -e "${GREEN}🎉 Збірка та завантаження успішно завершено!${NC}"
echo ""
echo -e "${BLUE}Наступні кроки:${NC}"
echo -e "${BLUE}1. Оновіть ваш Helm values.yaml з новим образом${NC}"
echo -e "${BLUE}2. Розгорніть в Kubernetes: helm upgrade --install django-app ./charts/django-app${NC}"
