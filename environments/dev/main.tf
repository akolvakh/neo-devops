# ======================
# DEV ENVIRONMENT INFRASTRUCTURE
# ======================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Backend конфігурація (оновлюється після створення backend)
  # backend "s3" {
  #   bucket         = "lesson-5-dev-tfstate-{account-id}"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "lesson-5-dev-terraform-locks"
  #   encrypt        = true
  # }
}

# ======================
# PROVIDER
# ======================

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# ======================
# DATA SOURCES
# ======================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ======================
# LOCALS
# ======================

locals {
  # Префікс для ресурсів
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Мережеві налаштування
  vpc_cidr = var.vpc_cidr_block
  
  # Динамічні підмережі
  public_subnets = [
    for i in range(var.subnet_count) : 
    cidrsubnet(local.vpc_cidr, 8, i + 1)
  ]
  
  private_subnets = [
    for i in range(var.subnet_count) : 
    cidrsubnet(local.vpc_cidr, 8, i + 4)
  ]
  
  # Зони доступності
  availability_zones = data.aws_availability_zones.available.names
  
  # Загальні теги
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
}

# ======================
# VPC MODULE
# ======================

module "vpc" {
  source = "../../modules/vpc"

  vpc_name           = "${local.resource_prefix}-vpc"
  vpc_cidr_block     = local.vpc_cidr
  public_subnets     = local.public_subnets
  private_subnets    = local.private_subnets
  availability_zones = slice(local.availability_zones, 0, var.subnet_count)
  
  tags = local.common_tags
}

# ======================
# ECR MODULE
# ======================

module "ecr" {
  source = "../../modules/ecr"

  ecr_name             = "${local.resource_prefix}-ecr"
  force_delete         = var.ecr_force_delete
  scan_on_push         = var.ecr_scan_on_push
  image_tag_mutability = var.ecr_image_tag_mutability
}
