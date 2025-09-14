# ======================
# BACKEND OUTPUTS
# ======================

output "s3_bucket_name" {
  description = "Назва створеного S3 bucket"
  value       = module.s3_backend.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN S3 bucket"
  value       = module.s3_backend.s3_bucket_arn
}

output "dynamodb_table_name" {
  description = "Назва створеної DynamoDB таблиці"
  value       = module.s3_backend.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN DynamoDB таблиці"
  value       = module.s3_backend.dynamodb_table_arn
}

# ======================
# BACKEND CONFIG FOR ENVIRONMENTS
# ======================

output "backend_config" {
  description = "Готова backend конфігурація для копіювання"
  value = <<-EOF
terraform {
  backend "s3" {
    bucket         = "${local.bucket_name}"
    key            = "${var.environment}/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${local.dynamodb_table}"
    encrypt        = true
  }
}
EOF
}
