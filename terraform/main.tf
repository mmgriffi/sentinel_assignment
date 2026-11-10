############## Compute Setup ###########################
# Reads the path from your variable to fetch the actual ID
data "aws_ssm_parameter" "ubuntu" {
  name = var.ubuntu_ami
}

# create ec2 instance
resource "aws_instance" "ec2_server" {
  ami                    = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_server.id]
  key_name               = var.keypair

  # Enforce IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforces IMDSv2
    http_put_response_hop_limit = 1
  }

  # Encrypt Root Block Device
  root_block_device {
    encrypted   = true
    volume_type = "gp3" # Recommended default for general purpose storage
  }


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
