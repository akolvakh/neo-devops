# ======================
# ТАБЛИЦІ МАРШРУТИЗАЦІЇ
# ======================

# Таблиця маршрутизації для публічних підмереж
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id                               # ID VPC

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-rt"
      Type = "public"
    }
  )
}

# Маршрут до інтернету через Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id     # ID таблиці маршрутизації
  destination_cidr_block = "0.0.0.0/0"                  # Весь трафік
  gateway_id             = aws_internet_gateway.igw.id   # Через Internet Gateway
}

# Асоціація публічних підмереж з таблицею маршрутизації
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)            # Для кожної публічної підмережі
  subnet_id      = aws_subnet.public[count.index].id     # ID підмережі
  route_table_id = aws_route_table.public.id             # ID таблиці маршрутизації
}

# ======================
# ПРИВАТНІ ТАБЛИЦІ МАРШРУТИЗАЦІЇ
# ======================

# Окремі таблиці маршрутизації для кожної приватної підмережі
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)                   # Для кожної приватної підмережі
  vpc_id = aws_vpc.main.id                               # ID VPC

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-rt-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "private"
    }
  )
}

# Асоціація приватних підмереж з їх таблицями маршрутизації
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)           # Для кожної приватної підмережі
  subnet_id      = aws_subnet.private[count.index].id    # ID підмережі
  route_table_id = aws_route_table.private[count.index].id # ID відповідної таблиці маршрутизації
}
