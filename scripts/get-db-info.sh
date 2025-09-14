#!/bin/bash

# ==============================================
# Database URL Retriever Script
# ==============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TERRAFORM_DIR="../../environments/dev"

echo -e "${BLUE}=== Retrieving Database Information ===${NC}"

# Check if terraform directory exists
if [ ! -d "${TERRAFORM_DIR}" ]; then
    echo -e "${RED}❌ Terraform directory not found: ${TERRAFORM_DIR}${NC}"
    exit 1
fi

cd ${TERRAFORM_DIR}

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo -e "${RED}❌ Terraform not initialized. Please run 'terraform init' first${NC}"
    exit 1
fi

echo -e "${YELLOW}Getting database information from Terraform outputs...${NC}"

# Get database information
DB_ENDPOINT=$(terraform output -raw db_instance_endpoint 2>/dev/null || echo "")
DB_NAME=$(terraform output -raw db_instance_name 2>/dev/null || echo "djangodb") 
DB_USER="dbadmin"  # From variables
DB_PASSWORD="TempPassword123!"  # From variables (в продакшене использовать AWS Secrets Manager)

if [ -z "${DB_ENDPOINT}" ]; then
    echo -e "${RED}❌ Could not retrieve database endpoint. Make sure RDS is deployed.${NC}"
    exit 1
fi

# Construct database URL
DATABASE_URL="postgres://${DB_USER}:${DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}"

echo -e "${GREEN}✅ Database information retrieved successfully${NC}"
echo ""
echo -e "${BLUE}=== Database Details ===${NC}"
echo -e "${GREEN}Endpoint: ${DB_ENDPOINT}${NC}"
echo -e "${GREEN}Database: ${DB_NAME}${NC}"
echo -e "${GREEN}Username: ${DB_USER}${NC}"
echo ""
echo -e "${BLUE}=== Database URL ===${NC}"
echo -e "${GREEN}${DATABASE_URL}${NC}"
echo ""

# Update Helm values if requested
if [ "$1" == "--update-helm" ]; then
    echo -e "${YELLOW}Updating Helm values.yaml...${NC}"
    
    HELM_VALUES_FILE="../../charts/django-app/values.yaml"
    
    if [ ! -f "${HELM_VALUES_FILE}" ]; then
        echo -e "${RED}❌ Helm values.yaml not found: ${HELM_VALUES_FILE}${NC}"
        exit 1
    fi
    
    # Create backup
    cp "${HELM_VALUES_FILE}" "${HELM_VALUES_FILE}.bak"
    
    # Update DATABASE_URL in values.yaml
    sed -i '' "s|DATABASE_URL:.*|DATABASE_URL: \"${DATABASE_URL}\"|" "${HELM_VALUES_FILE}"
    
    echo -e "${GREEN}✅ Helm values.yaml updated${NC}"
    echo -e "${YELLOW}Backup saved as: ${HELM_VALUES_FILE}.bak${NC}"
fi

echo ""
echo -e "${BLUE}Usage:${NC}"
echo -e "${BLUE}  To update Helm values: $0 --update-helm${NC}"
echo -e "${BLUE}  To test connection: psql \"${DATABASE_URL}\"${NC}"
