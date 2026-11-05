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
#This file pins the binary version of Terraform and lock down the external plugin versions