# ======================
# BACKEND INFRASTRUCTURE
# ======================
# Створює S3 bucket та DynamoDB для Terraform remote state

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
  
  # Backend проект використовує локальний state
}


# ======================
# PROVIDER
# ======================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment  
      Purpose     = "terraform-backend"
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

# ======================
# DATA SOURCES
# ======================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ======================
# LOCALS
# ======================

locals {
  # Префікс для ресурсів
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Унікальні назви з Account ID
  bucket_name    = "${local.resource_prefix}-tfstate-${data.aws_caller_identity.current.account_id}"
  dynamodb_table = "${local.resource_prefix}-terraform-locks"
  
  # Теги для модуля
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Purpose     = "terraform-backend"
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
}

# ======================
# S3 BACKEND MODULE
# ======================

module "s3_backend" {
  source = "../modules/s3-backend"

  # Назви ресурсів
  bucket_name        = local.bucket_name
  dynamodb_table     = local.dynamodb_table
  env_name           = var.environment
  
  # Налаштування
  enable_versioning  = var.enable_s3_versioning
  force_destroy      = var.s3_bucket_force_destroy
  
  # Теги
  tags = local.common_tags
}
