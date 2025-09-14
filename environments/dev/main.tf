# ======================
# ІНФРАСТРУКТУРА DEV СЕРЕДОВИЩА
# ======================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# ======================
# ПРОВАЙДЕР AWS
# ======================

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# ======================
# ДЖЕРЕЛА ДАНИХ
# ======================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ======================
# ЛОКАЛЬНІ ЗМІННІ
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
# МОДУЛЬ VPC
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
# МОДУЛЬ ECR
# ======================

module "ecr" {
  source = "../../modules/ecr"

  ecr_name             = "${local.resource_prefix}-ecr"
  force_delete         = var.ecr_force_delete
  scan_on_push         = var.ecr_scan_on_push
  image_tag_mutability = var.ecr_image_tag_mutability
}

# ======================
# МОДУЛЬ БД
# ======================

module "rds" {
  source = "../../modules/rds"
  
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  
  tags = local.common_tags
}

# ======================
# МОДУЛЬ EKS
# ======================
module "eks" {
  source = "../../modules/eks"
  
  cluster_name  = var.cluster_name              # Назва кластера
  subnet_ids    = module.vpc.public_subnets     # Використовуємо публічні підмережі для dev
  instance_type = var.instance_type             # Тип інстансів
  desired_size  = 2                             # Бажана кількість вузлів
  max_size      = 3                             # Максимальна кількість вузлів
  min_size      = 1                             # Мінімальна кількість вузлів
  
  vpc_id = module.vpc.vpc_id
  
  tags = local.common_tags
}

# ======================
# КОНФІГУРАЦІЯ ПРОВАЙДЕРІВ KUBERNETES
# ======================

data "aws_eks_cluster" "eks" {
  name       = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}