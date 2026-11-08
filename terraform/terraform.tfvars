#These are used a overrides for any defaults in the variables.tf 
# AWS Configuration
aws_region = "eu-west-1"
#aws_region = "us-east-1"

# Project Configuration
project_name = "sentinel-aws-test"
environment  = "dev"

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet-a_cidr  = "10.0.2.0/24"
private_subnet-b_cidr   = "10.0.3.0/24"

# update to match your current IP address
admin_ip  = "86.45.159.23/32"

# EC2 Configuration
instance_type    = "t2.micro"

#ubuntu_ami
ubuntu_ami = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"

## Passing a single variable
#terraform plan -var="environment=production"

# Passing multiple variables
#terraform apply -var="environment=production" -var="instance_count=5"