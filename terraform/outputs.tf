# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# VPC CIDR Block
output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Public Subnet ID
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

# Private Subnet A ID
output "private_subnet_id" {
  description = "ID of the private subnet B"
  value       = aws_subnet.privateA.id
}

# Private Subnet B ID
output "private_subnet-a_id" {
  description = "ID of the private subnet A"
  value       = aws_subnet.privateB.id
}

# Internet Gateway ID
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Security Group ID
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_server.id
}

# EC2 Instance ID
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_server.id
}

# EC2 Instance Public IP
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2_server.public_ip
}

# EC2 Instance Private IP
output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ec2_server.private_ip
}

# EC2 Instance Public DNS
output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ec2_server.public_dns
}

# SSH Connection Command
output "ssh_connection_command" {
  description = "Command to SSH into the EC2 instance"
  value       = "ssh -i ~/.ssh/terraform-aws-key ubuntu@${aws_instance.ec2_server.public_ip}"
}
# Output the database endpoint for easy connection referencing
output "db_endpoint" {
  description = "The connection endpoint for the MySQL RDS database"
  value       = aws_db_instance.mysql_db.endpoint
}

# Output the exact S3 Bucket Name for script configurations
output "backup_s3_bucket_name" {
  description = "The unique name of the S3 bucket created for database backups"
  value       = aws_s3_bucket.db_backups.id
}

# Output the ready-to-use S3 URI string path
output "backup_s3_uri" {
  description = "The target S3 URI path to copy backup files directly to"
  value       = "s3://${aws_s3_bucket.db_backups.id}/"
}