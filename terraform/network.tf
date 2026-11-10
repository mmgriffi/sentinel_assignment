############ Network Component Setup ##########
# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
    Type        = "Public"
  }
}

# Create Private Subnet A
resource "aws_subnet" "privateA" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet-a_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-private-subnet-a"
    Environment = var.environment
    Type        = "Private"
  }
}

# Create Private Subnet B
resource "aws_subnet" "privateB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet-b_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-private-subnet-b"
    Environment = var.environment
    Type        = "Private"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Create Route Table for Private  Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Associate Route Table with Private  Subnets
resource "aws_route_table_association" "privateB" {
  subnet_id      = aws_subnet.privateB.id
  route_table_id = aws_route_table.private.id
}

# Associate Route Table with Private  Subnets
resource "aws_route_table_association" "privateA" {
  subnet_id      = aws_subnet.privateA.id
  route_table_id = aws_route_table.private.id
}

# Create Security Group for EC2 
resource "aws_security_group" "ec2_server" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group allowing SSH"
  vpc_id      = aws_vpc.main.id

# SSH access restricted to 1 IP address
  ingress {
    description = "SSH from anywhere"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # Outbound internet access
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }
}

# Security Group for database. 
resource "aws_security_group" "db_server" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database allowing access from EC2 only"
  vpc_id      = aws_vpc.main.id

  # Secure Path: Allows 3306 traffic ONLY originating from your ec2_server security group
  ingress {
    description     = "Allow MySQL traffic from EC2 server"
    from_port       = var.sql_port
    to_port         = var.sql_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_server.id]
  }

  # Outbound internet access
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-db-sg"
    Environment = var.environment
  }
}

# DB Subnet Group (Combines privateA and privateB to satisfy AWS requirements)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.project_name}-rds-subnet-group"
  description = "Database subnet group containing private subnets"
  subnet_ids  = [aws_subnet.privateA.id, aws_subnet.privateB.id]
  tags = {
    Name        = "${var.project_name}-rds-subnet-group"
    Environment = var.environment
  }
}