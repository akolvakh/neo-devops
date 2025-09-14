
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
}

output "s3_bucket_name" {
  value       = var.bucket_name
}

output "s3_bucket_url" {
  value       = "https://${var.bucket_name}.s3.amazonaws.com"
}
