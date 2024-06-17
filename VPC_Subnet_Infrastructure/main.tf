resource "aws_vpc" "example" { 
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_internet_gateway" "example" { 
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "example-igw"
  }
}

resource "aws_route_table" "public" { 
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "example-public-rt"
  }
}

resource "aws_eip" "nat_gateway" { 
  count = var.nat_gateway_count

  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "example" { 
  count = var.nat_gateway_count

  subnet_id = aws_subnet.public[count.index % var.public_subnet_count].id

  allocation_id = aws_eip.nat_gateway[count.index].id

  tags = {
    Name = "example-nat-gateway-${count.index}"
  }
}

resource "aws_route_table" "private" { 
  count = var.private_subnet_count

  vpc_id = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example[count.index % var.nat_gateway_count].id
  }

  tags = {
    Name = "example-private-rt-${count.index}"
  }
}

resource "aws_route_table_association" "public" { 
  count = var.public_subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" { 
  count = var.private_subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

locals { 
  base_cidr_block      = var.vpc_cidr_block
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  host_count           = var.hosts_per_subnet
  subnet_cidrs = [
    for i in range(var.public_subnet_count + var.private_subnet_count) :
    cidrsubnet(var.vpc_cidr_block, 8, i)
  ]
  public_subnet_start_index  = 0
  private_subnet_start_index = var.public_subnet_count
}

resource "aws_subnet" "public" { 
  count = local.public_subnet_count

  cidr_block = local.subnet_cidrs[local.public_subnet_start_index + count.index]
  vpc_id     = aws_vpc.example.id

  tags = {
    Name = "public-subnet-${count.index}"
    Type = "Public"
  }
}

resource "aws_subnet" "private" { 
  count = local.private_subnet_count

  cidr_block = local.subnet_cidrs[local.private_subnet_start_index + count.index]
  vpc_id     = aws_vpc.example.id

  tags = {
    Name = "private-subnet-${count.index}"
    Type = "Private"
  }
}
