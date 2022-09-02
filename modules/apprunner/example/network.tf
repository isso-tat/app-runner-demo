resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "external_gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "externalGateway"
  }
}

resource "aws_subnet" "server_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "apprunner_subnet"
  }
}

resource "aws_subnet" "server_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "apprunner_subnet"
  }
}

resource "aws_subnet" "server_subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "apprunner_subnet"
  }
}

resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.31.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "public_subnet_1d" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_security_group" "server_sg" {
  name        = "server_sg"
  description = "Security group for AppRunner service."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Incoming SSL connection from application."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Egress security rule."
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "server_security_group"
  }
}

resource "aws_eip" "server_eip_1a" {
  vpc        = true
  depends_on = [aws_internet_gateway.external_gw]
  tags = {
    "Name" = "ServerEIP-1a"
  }
}

resource "aws_nat_gateway" "nat_gw_1a" {
  subnet_id     = aws_subnet.public_subnet_1a.id
  allocation_id = aws_eip.server_eip_1a.id
  tags = {
    Name = "NATgw-1a"
  }
}

resource "aws_eip" "server_eip_1c" {
  vpc        = true
  depends_on = [aws_internet_gateway.external_gw]
  tags = {
    "Name" = "ServerEIP-1c"
  }
}

resource "aws_nat_gateway" "nat_gw_1c" {
  subnet_id     = aws_subnet.public_subnet_1c.id
  allocation_id = aws_eip.server_eip_1c.id
  tags = {
    Name = "NATgw-1c"
  }
}

resource "aws_eip" "server_eip_1d" {
  vpc        = true
  depends_on = [aws_internet_gateway.external_gw]
  tags = {
    "Name" = "ServerEIP-1d"
  }
}

resource "aws_nat_gateway" "nat_gw_1d" {
  subnet_id     = aws_subnet.public_subnet_1d.id
  allocation_id = aws_eip.server_eip_1d.id
  tags = {
    Name = "NATgw-1d"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PublicRouteTable"
  }
}

# InternetGW - Public subnet routes.
resource "aws_route" "public_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.external_gw.id
}

resource "aws_route_table_association" "public_route_assoc_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_assoc_1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_assoc_1d" {
  subnet_id      = aws_subnet.public_subnet_1d.id
  route_table_id = aws_route_table.public_route_table.id
}

# Public - Private subnet routes.
resource "aws_route_table" "private_route_table_1a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PrivateRouteTable-1a"
  }
}

resource "aws_route_table" "private_route_table_1c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PrivateRouteTable-1c"
  }
}

resource "aws_route_table" "private_route_table_1d" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PrivateRouteTable-1d"
  }
}

resource "aws_route" "private_route_1a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_route_table_1a.id
  nat_gateway_id         = aws_nat_gateway.nat_gw_1a.id
}

resource "aws_route" "private_route_1c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_route_table_1c.id
  nat_gateway_id         = aws_nat_gateway.nat_gw_1c.id
}

resource "aws_route" "private_route_1d" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_route_table_1d.id
  nat_gateway_id         = aws_nat_gateway.nat_gw_1d.id
}

resource "aws_route_table_association" "private_route_assoc_1a" {
  subnet_id      = aws_subnet.server_subnet.id
  route_table_id = aws_route_table.private_route_table_1a.id
}

resource "aws_route_table_association" "private_route_assoc_1c" {
  subnet_id      = aws_subnet.server_subnet2.id
  route_table_id = aws_route_table.private_route_table_1c.id
}

resource "aws_route_table_association" "private_route_assoc_1d" {
  subnet_id      = aws_subnet.server_subnet3.id
  route_table_id = aws_route_table.private_route_table_1d.id
}