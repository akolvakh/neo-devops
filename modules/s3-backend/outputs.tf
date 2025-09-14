
# ======================
# S3 BACKEND MODULE OUTPUTS
# ======================

output "s3_bucket_name" {
  description = "Назва створеного S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_url" {
  description = "URL S3 bucket"
  value       = "https://${aws_s3_bucket.terraform_state.bucket}.s3.amazonaws.com"
}

output "dynamodb_table_name" {
  description = "Назва створеної DynamoDB таблиці"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN DynamoDB таблиці"
  value       = aws_dynamodb_table.terraform_locks.arn
}
