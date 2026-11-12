# AWS Region
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-west-1"
}

# Project Name
variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "sentinel-aws-test"
}

# Environment
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public Subnet CIDR
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Private SubnetA CIDR
variable "private_subnet-a_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# Private SubnetB CIDR
variable "private_subnet-b_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

# SSH private IP
variable "admin_ip" {
  description = "IP address of the user laptop"
  type        = string
  default     = "10.10.10.10/32"
}

# EC2 Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Key pair name
variable "keypair" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "3tierassignment"
}

#AMI 
variable "ubuntu_ami" {
    description = "full path of the AMI"
    type = string
    default = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

#db_username
variable "db_username" {
    description = "Master DB username"
    type        = string
    default     = "dbadmin"
}

#db_password
variable "db_password" {
    description = "Master DB password"
    type        = string
    default     = "dbpassword"
    sensitive   = "true"
}
# SSH port
#db_password
variable "ssh_port" {
    description = "ssh_port for inbound access"
    type        = string
    default     = "22"
}
# SQL port
#db_password
variable "sql_port" {
    description = "SQL db port for inbound access"
    type        = string
    default     = "3306"
}