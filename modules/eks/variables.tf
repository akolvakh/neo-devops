variable "region" {
  description = "AWS регіон для розгортання"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
  default     = "lesson-7-eks-cluster"
}

variable "subnet_ids" {
  description = "Список ID підмереж для EKS кластера"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID VPC де буде розгорнуто EKS"
  type        = string
}

variable "node_group_name" {
  description = "Назва групи вузлів"
  type        = string
  default     = "lesson-7-node-group"
}

variable "instance_type" {
  description = "Тип EC2 інстансів для робочих вузлів"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Бажана кількість робочих вузлів"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Максимальна кількість робочих вузлів"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Мінімальна кількість робочих вузлів"  
  type        = number
  default     = 1
}

variable "tags" {
  description = "Теги для застосування до EKS ресурсів"
  type        = map(string)
  default     = {}
}