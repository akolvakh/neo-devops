output "eks_cluster_endpoint" {
  description = "EKS API ендпоінт для підключення до кластера"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = aws_eks_cluster.eks.name
}

output "eks_node_role_arn" {
  description = "ARN IAM ролі для EKS робочих вузлів"
  value       = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  description = "ARN OIDC провайдера"
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  description = "URL OIDC провайдера"
  value = aws_iam_openid_connect_provider.oidc.url
}