# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

# --- Public Subnets ---
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.100.0.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project}-public-a"
    Project                  = var.project
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.100.16.0/20"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project}-public-b"
    Project                  = var.project
    "kubernetes.io/role/elb" = "1"
  }
}

# --- Private Subnets ---
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.32.0/20"
  availability_zone = "${var.region}a"

  tags = {
    Name                              = "${var.project}-private-a"
    Project                           = var.project
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.48.0/20"
  availability_zone = "${var.region}b"

  tags = {
    Name                              = "${var.project}-private-b"
    Project                           = var.project
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# --- NAT Gateway (1x in public AZ A) ---

resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name    = "${var.project}-nat-eip"
    Project = var.project
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }

  depends_on = [aws_internet_gateway.igw]
}

# --- Route Tables ---

# Public RT: route 0.0.0.0/0 -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-public-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private RT: route 0.0.0.0/0 -> NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-private-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
