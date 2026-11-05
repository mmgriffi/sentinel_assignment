# Configure Terraform and AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.69"
    }
  }
  required_version = ">= 1.16.3"
}

provider "aws" {
  region = var.aws_region
}

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
    from_port   = 22
    to_port     = 22
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
    from_port       = 3306
    to_port         = 3306
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

############## Compute Setup ###########################
# Reads the path from your variable to fetch the actual ID
data "aws_ssm_parameter" "ubuntu" {
  name = var.ubuntu_ami
}

# Create EC2 Instance
resource "aws_instance" "ec2_server" {
  ami                    = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_server.id]
  key_name               = var.keypair

  # Fix: Links the IAM profile directly to your virtual machine resource
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # User data script to install just mariadb client
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y mariadb-client-core awscli
              curl -o /home/ubuntu/global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
              EOF

  tags = {
    Name        = "${var.project_name}-ec2-server"
    Environment = var.environment
  }
}

# Single-AZ MySQL RDS Database 
resource "aws_db_instance" "mysql_db" {
  identifier           = "${var.project_name}-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  skip_final_snapshot  = true

  backup_retention_period = 0

  # Constraints: Forces DB into privateA's AZ and disables replication
  availability_zone    = aws_subnet.privateA.availability_zone
  multi_az             = false

  # Networking & Security
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_server.id]

  # Credentials (Handled via your variables)
  username             = var.db_username
  password             = var.db_password

  tags = {
    Name        = "${var.project_name}-mysql-db"
    Environment = var.environment
  }
}

# Create the dedicated S3 backup storage vault
resource "aws_s3_bucket" "db_backups" {
  bucket        = "${var.project_name}-db-backups-assignment"
  #force_destroy = true # Allows easy cleanup but will DUMP everything. Set to false will leave the bucket in place. 
  force_destroy = false 
}

# IAM Policy allowing EC2 to drop files into this specific bucket
resource "aws_iam_policy" "s3_upload_policy" {
  name        = "${var.project_name}-s3-upload-policy"
  description = "Allows EC2 instance to upload database backups to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "${aws_s3_bucket.db_backups.arn}/*"
      }
    ]
  })
}

# 1. Create the IAM Role that allows EC2 instances to assume it
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Attach your S3 upload policy to the IAM Role
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}

# 3. Create the Instance Profile (The wrapper required by EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}
