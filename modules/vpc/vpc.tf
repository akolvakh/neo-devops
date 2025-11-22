# Створення основної VPC мережі
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block       # CIDR блок для VPC
  enable_dns_support   = true                    # Увімкнення DNS підтримки
  enable_dns_hostnames = true                    # Увімкнення DNS імен хостів

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

# Створення публічних підмереж
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)      # Кількість публічних підмереж
  vpc_id                  = aws_vpc.main.id                 # ID VPC
  cidr_block              = var.public_subnets[count.index] # CIDR блок підмережі
  availability_zone       = var.availability_zones[count.index] # Зона доступності
  map_public_ip_on_launch = true                            # Автоматичне призначення публічного IP

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "public"
      Tier = "web"
    }
  )
}

# Створення приватних підмереж
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)           # Кількість приватних підмереж
  vpc_id            = aws_vpc.main.id                       # ID VPC
  cidr_block        = var.private_subnets[count.index]      # CIDR блок підмережі
  availability_zone = var.availability_zones[count.index]   # Зона доступності

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "private"
      Tier = "app"
    }
  )
}

# Створення Internet Gateway для доступу до інтернету
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id                               # Прив'язка до VPC

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}
