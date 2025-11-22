# ======================
# VPC MODULE OUTPUTS
# ======================

# VPC Outputs
output "vpc_id" {
  description = "ID створеного VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR блок VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN VPC"
  value       = aws_vpc.main.arn
}

# Subnet Outputs
output "public_subnets" {
  description = "Список ID публічних підмереж"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Список ID приватних підмереж"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR блоки публічних підмереж"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR блоки приватних підмереж"
  value       = aws_subnet.private[*].cidr_block
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID таблиці маршрутизації для публічних підмереж"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Список ID таблиць маршрутизації для приватних підмереж"
  value       = aws_route_table.private[*].id
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = aws_internet_gateway.igw.id
}
