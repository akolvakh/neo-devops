output "ecr_repo_url" {
  value       = "https://${aws_ecr_repository.ecr.repository_url}"
}

output "ecr_repo_arn" {
  value       = aws_ecr_repository.ecr.arn
}