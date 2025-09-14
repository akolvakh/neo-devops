output "s3_bucket_name" {
  value       = module.s3_backend.s3_bucket_name
}

output "s3_bucket_url" {
  value       = module.s3_backend.s3_bucket_url
}

output "vpc_id" {
  value       = module.vpc.vpc_id
}

output "public_subnet" {
  value       = module.vpc.public_subnets
}

output "private_subnet" {
  value       = module.vpc.private_subnets
}

output "ecr_repo_url" {
  value       = module.ecr.ecr_repo_url
}
