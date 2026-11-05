# Sentinel/Terraform Assignment.

## Introduction

This assignment demonstrates creating Policy-as-code using Terraform and Sentinal. The intent is to enforce sovereignty for Ireland and IaC supply chain security requirements, and demonstrate policy enforcement in non-compliant and compliant situations. 

## Areas
  - Digital sovereignty Policies: 
     - restrict infrastructure to defined geo. regions.
     - enfore data residency reguirements for resrouces storing sensitive infomation. 
  - IaC supply chain security : 
     - Restrict Terraform providers to appoved sources.
     - Enfore appoved provider versions. 
     - Require (trusted?) Terraform module sources and specific versions. 
  - Infrastructure security policies:
     - Approved EC2 instance types
     - Encrypted EBS storage.
     - Implement IMDSv2.
     - Approiate network security considerations. 
     - Restrictions on inbound SSH access. 


## Test environment.

This environment has a single EC2 instance, RDS SQL database (1 node) and S3 storage (intended for backups/data copy within the environment). 


main.tf : All AWS resource definitions
variables.tf : Input variable declarations
outputs.tf : Values to display after deployment
terraform.tfvars : Actual variable values
network.tf <to be created>
providers.tf <to be created>
versions.tf <to be created>







Test backup. 
````
echo "Database backup test file data" > backup_test.sql
aws s3 cp backup_test.sql s3://terraform-aws-vm-db-backups-assignment/
upload: ./backup_test.sql to s3://terraform-aws-vm-db-backups-assignment/backup_test.sql
````

 mysql -h terraform-aws-vm-mysql.cxiwko4io48i.eu-west-1.rds.amazonaws.com -P 3306 -u dbadmin -p --ssl-ca=./global-bundle.pem


# Resources used.
- Used in "3.0 Terraform AWS_2026.pdf" to create an EC2 instance. Changed to use my assignment VPC/subnet from the 1st assigment. Allowed me login and validate.
  - Changed the IAM and use plan / apply to update the instance.
  - Destory.
 - Used "4_0 Terraform AWS_2026.pdf" to create storage with variables. 

(This got me started with basic Terraform. )

- I used a tutorial on https://aws.plainenglish.io/  . This gave a walkthrough on a single node webserver , 1 vpc + 2 subnets.  [link](https://aws.plainenglish.io/building-aws-vpc-and-ec2-infrastructure-with-terraform-a-hands-on-devops-tutorial-4955eac76f4f)

I modified this as follows : 
 - remove webserver components, just add a mysql client.
 - Add single node RDS SQL database. This required additional subnet and RDS subnet (AWS requirement)
 - Network changes to only allow port 22 from my laptop to the EC2 instance. From there use the mysql client.
 - Added s3 storage bucket.  This will be a backup location. To access from the EC2 instance it required an IAM role and policy.


# Accounts
- Created HCP Cloud Account and Terraform HCP accounts.  From the classes earlier found that when the Terraform HCP account was created, adding the HCP Cloud account after forced it to try and link both, but the link broke.  Ended up (a number of hours) trying to delete the accounts and start over with a new ID. Very problematic. 

# Terraform 

https://developer.hashicorp.com/terraform/language/style

https://discuss.hashicorp.com/t/tool-to-convert-cloudformation-to-terraform/46704

https://aws.plainenglish.io/building-aws-vpc-and-ec2-infrastructure-with-terraform-a-hands-on-devops-tutorial-4955eac76f4f



# Sentinel

