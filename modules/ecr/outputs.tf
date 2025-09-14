output "ecr_repo_url" {
  description = "URL ECR репозиторію"
  value       = "https://${aws_ecr_repository.ecr.repository_url}"
}

output "ecr_repo_arn" {
  description = "ARN ECR репозиторію"
  value       = aws_ecr_repository.ecr.arn
}