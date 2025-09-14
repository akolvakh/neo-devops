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

  name                    = var.name
  use_aurora              = var.use_aurora
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  instance_class          = var.instance_class
  engine                  = var.engine
  engine_version          = var.engine_version
  engine_cluster          = var.engine_cluster
  engine_version_cluster  = var.engine_version_cluster
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  aurora_replica_count    = var.aurora_replica_count
  max_allocated_storage   = var.max_allocated_storage

  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_private_ids = module.vpc.private_subnets
  subnet_public_ids  = module.vpc.public_subnets

  parameter_group_family_rds    = var.parameter_group_family_rds
  parameter_group_family_aurora = var.parameter_group_family_aurora

  parameters = {
    max_connections = "200"
    log_statement   = "none"
    work_mem        = "4096"
  }

  tags = local.common_tags

  depends_on = [module.vpc]
}


# ======================
# МОДУЛЬ EKS
# ======================
module "eks" {
  source = "../../modules/eks"

  cluster_name  = var.cluster_name          # Назва кластера
  subnet_ids    = module.vpc.public_subnets # Використовуємо публічні підмережі для dev
  instance_type = var.instance_type         # Тип інстансів
  desired_size  = 2                         # Бажана кількість вузлів
  max_size      = 3                         # Максимальна кількість вузлів
  min_size      = 1                         # Мінімальна кількість вузлів

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

# ======================
# МОДУЛЬ JENKINS
# ======================

module "jenkins" {
  source            = "../../modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_pat        = var.github_pat
  github_user       = var.github_user
  github_repo_url   = var.github_repo_url
  depends_on        = [module.eks]
  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

# ======================
# МОДУЛЬ ARGOCD
# ======================

module "argo_cd" {
  source          = "../../modules/argo_cd"
  namespace       = "argocd"
  chart_version   = "5.46.4"
  github_user     = var.github_user
  github_pat      = var.github_pat
  github_repo_url = var.github_repo_url
  depends_on      = [module.eks]
  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

# ======================
# СЕКРЕТ ДЛЯ DJANGO ПРИЛОЖЕНИЯ
# ======================

resource "kubernetes_secret" "django_app_secret" {
  metadata {
    name      = "example-app-django-app-secret"
    namespace = "default"
  }

  data = {
    database-url = "postgresql://${var.username}:${var.password}@${module.rds.db_instance_hostname}:${module.rds.db_instance_port}/${module.rds.db_instance_name}"
  }

  type = "Opaque"

  depends_on = [module.eks]
}

# ======================
# СЕКРЕТ GITHUB ДЛЯ JENKINS
# ======================

resource "kubernetes_secret" "jenkins_github_credentials" {
  metadata {
    name      = "jenkins-github-credentials"
    namespace = "jenkins"
    labels = {
      "jenkins.io/credentials-type" = "usernamePassword"
    }
    annotations = {
      "jenkins.io/credentials-description" = "GitHub credentials for Jenkins"
    }
  }

  data = {
    username = var.github_user
    password = var.github_pat
  }

  type = "Opaque"

  depends_on = [module.jenkins]
}