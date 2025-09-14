#!/bin/bash

# ==============================================
# Скрипт налаштування EKS кластера
# ==============================================

set -e

# Кольори
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Конфігурація
CLUSTER_NAME="eks-cluster-lesson-7"
REGION="us-east-1"

echo -e "${BLUE}=== Налаштування EKS кластера ===${NC}"
echo -e "${BLUE}Кластер: ${CLUSTER_NAME}${NC}"
echo -e "${BLUE}Регіон: ${REGION}${NC}"
echo ""

# Перевірити, чи встановлений та налаштований AWS CLI
echo -e "${YELLOW}Перевірка AWS CLI...${NC}"
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI не встановлений${NC}"
    exit 1
fi

if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo -e "${RED}❌ AWS CLI не налаштований або креденшали недійсні${NC}"
    exit 1
fi
echo -e "${GREEN}✅ AWS CLI налаштований${NC}"

# Перевірити, чи встановлений kubectl
echo -e "${YELLOW}Перевірка kubectl...${NC}"
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl не встановлений${NC}"
    echo -e "${YELLOW}Встановлення kubectl...${NC}"
    
    # Встановити kubectl для macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install kubectl
        else
            echo -e "${RED}❌ Будь ласка, встановіть kubectl вручну або встановіть Homebrew${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Будь ласка, встановіть kubectl вручну${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✅ kubectl доступний${NC}"

# Перевірити, чи існує EKS кластер
echo -e "${YELLOW}Перевірка існування EKS кластера...${NC}"
if ! aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION} > /dev/null 2>&1; then
    echo -e "${RED}❌ EKS кластер '${CLUSTER_NAME}' не існує або не готовий${NC}"
    echo -e "${YELLOW}Переконайтеся, що кластер створений і працює${NC}"
    exit 1
fi
echo -e "${GREEN}✅ EKS кластер існує${NC}"

# Оновити kubeconfig
echo -e "${YELLOW}Оновлення kubeconfig...${NC}"
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ kubeconfig успішно оновлено${NC}"
else
    echo -e "${RED}❌ Не вдалося оновити kubeconfig${NC}"
    exit 1
fi

# Тестувати підключення до кластера
echo -e "${YELLOW}Тестування підключення до кластера...${NC}"
kubectl get nodes
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Успішно підключено до EKS кластера${NC}"
else
    echo -e "${RED}❌ Не вдалося підключитися до EKS кластера${NC}"
    exit 1
fi

# Отримати інформацію про кластер
echo ""
echo -e "${BLUE}=== Інформація про кластер ===${NC}"
echo -e "${GREEN}Назва кластера: ${CLUSTER_NAME}${NC}"
echo -e "${GREEN}Регіон: ${REGION}${NC}"
kubectl cluster-info
echo ""

# Список вузлів
echo -e "${BLUE}=== Робочі вузли ===${NC}"
kubectl get nodes -o wide
echo ""

# Список подів у всіх namespace
echo -e "${BLUE}=== Системні поди ===${NC}"
kubectl get pods --all-namespaces
echo ""

echo -e "${GREEN}🎉 EKS кластер готовий!${NC}"
echo ""
echo -e "${BLUE}Наступні кроки:${NC}"
echo -e "${BLUE}1. Зібрати та завантажити Docker образ: ./scripts/build-and-push.sh${NC}"
echo -e "${BLUE}2. Розгорнути додаток: helm upgrade --install django-app ./charts/django-app${NC}"
