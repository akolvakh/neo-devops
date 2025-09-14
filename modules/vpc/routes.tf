# ======================
# ROUTE TABLES
# ======================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id 

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-rt"
      Type = "public"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ======================
# PRIVATE ROUTE TABLES
# ======================

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id 

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-rt-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "private"
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
