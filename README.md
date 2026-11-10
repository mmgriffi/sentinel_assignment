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

## Terraform & Test environment.
This environment has a single EC2 instance, RDS SQL database (1 node) and S3 storage (intended for backups/data copy within the environment). 
(overkill for this assignment, but I wanted to learn terraform more.)

This [tutorial](https://aws.plainenglish.io/building-aws-vpc-and-ec2-infrastructure-with-terraform-a-hands-on-devops-tutorial-4955eac76f4f) gave me the initial script setup (main.tf really).  Following the assignment and other prompts I split the script as follows :  

To give a scenario I could test and experiment with sentinel I modified my terraform as follows : 
 - remove webserver components, just use a basic EC2 instance and add a mysql client.
 - Add single node RDS SQL database. From learning on an earlier assignment this required additional subnet and RDS subnet (AWS requirement)
 - Network changes to only allow port 22 from my laptop to the EC2 instance. From there use the mysql client.
 - Added s3 storage bucket.  This will be a backup location. To access from the EC2 instance it required an IAM role and policy.
- Split the main.tf into component files, ensured variables were used throughout and listed once on the variables.tf file. terraform.tfvars acts as an override. 

````
|--terraform
   |
   |-main.tf       AWS resource definition
   |-network.tf    Network components
   |-providers.tf  Provider versions.
   |-versions.tf   Terraform versions
   |-outputs.tf    Outputs to display after deployment
   |-variables.tf  Variable definition with defaults.
   |-terraform.tfvars actual variable values / overrides.
````
I stood up the environment using Terraform apply and validatd some of the relevant aspects (all components in correct region, access between EC2 and RDS and S3 .. again , overkill)

## Sentinel.
- I created a HashiCorp Cloud and HCP Terraform accounts , downloaded the sentinel binary file.
- Followed assignment/Gemini on structuring the sentinel files, test folders and content. 
- Created an organisation, project "sentinel-test" and workspace "Work_Sentinel_test" on Terraform hcl and linked this github repository to it.
- In the organisation, I needed to create "individually managed policies" and a policy set to cover them. The Terraform free tier has restictions:
  - 1 policy set. (for free-tier this cannot be created by linking to GitHub and reading the sentinel.hcl / .sentinel files)
  - 1 policy only may be set "Hard Manadatory" or "Soft Mandatory", the rest needed to be "Advisory".
- Created a run (plan only) which generated mock/test data to download. Extracted files and placed this in the terraform folder. [zipfile](/terraform/run-JvxYqKbp68aBDmy4-sentinel-mocks.tar.gz)

For an Enterprise /production environment, the Policies should be maintained in a seperate GitHub repository from terraform code. This would allow policy changes to be written in the .sentinel files and reflected automatically in the policy set. Also, following best practices in both security & seperation of duty, managing policies should be restricted. 
[Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/permissions/organization)


- Gemini had given me the policy definition suitale for instance-type, soverignity and allowed-providers. 
  - With the mock data these pass. 
  - I was able to substitute instance types, regions that were not allowed in the .sentinel files and these failed/flagged as expected when executed via CLI 
   
## Create test runs  

https://app.terraform.io/app/atuIAC-terraform-mmgriffi-tf-org/workspaces

The test runs generated a plan and policy 

|Policy Name|Details|Passing Image|Failing Image|Notes
|----|----|----|----|----|
|Sovergnity|limited to a single region "allowed_regions = ["eu-west-1"]"   |![Pass](/images/TerraformUI_Apply_Passed_Sovereignty.jpg)|![Fail](/images/TerraformUI_Apply_Failed_Sovereignty.jpg)|To test switch terrafrom.tfvars to aws_region = "us-east-1", commit changes to GitHub and re-trigger Terraform UI run for new plan|
|Instance-type|uses array of instance types````"allowed_types = ["t3.micro", "t3.small","t2.micro"]"````and ensure ebs is encrypted and IMDSv2 is enabled|![Pass](/images/TerraformUI_Apply_Passed_Sovereignty.jpg)|![Fail/Advisory](/images/TerraformUI_FailAdvisory_Instance-type.jpg)|To test, updated main.tf with IMDSV2 , encryption settings and re-ran plan|
|Network|check if port 22 is open to 0.0.0.0/0 (if so flag unbound acccess), ensure only public subnets route to internet, ensure db security group ingress only has port 3306  |||
|allowed-providers|limit providers using ````allowed_providers = ["registry.terraform.io/hashicorp/aws",]````|||

Note: Terraform Policy definitions only allow 1 hard enforcement so I needed to configure others as advisory.
- 
see [logs](documentation\run-evumM51u7MjMAAKA-policy-check-log.txt)


# Resources used.
- "3.0 Terraform AWS_2026.pdf" to create an EC2 instance. Changed to use my assignment VPC/subnet from the 1st assigment. Allowed me login and validate.
  - Changed the IAM and use plan / apply to update the instance.
  - Destory.
 - "4_0 Terraform AWS_2026.pdf" to create storage with variables. 

(This got me started with basic Terraform. )

- This tutorial gave a walkthrough on a single node webserver , 1 vpc + 2 subnets.  [link](https://aws.plainenglish.io/building-aws-vpc-and-ec2-infrastructure-with-terraform-a-hands-on-devops-tutorial-4955eac76f4f)




# Links
https://medium.com/@bicutler/using-hashicorp-sentinel-to-implement-policy-as-code-within-your-terraform-provisioning-workflow-c89aac0ecc8

https://mattias.engineer/blog/2024/hashicorp-sentinel-with-terraform/

https://developer.hashicorp.com/terraform/language/style

https://discuss.hashicorp.com/t/tool-to-convert-cloudformation-to-terraform/46704

https://aws.plainenglish.io/building-aws-vpc-and-ec2-infrastructure-with-terraform-a-hands-on-devops-tutorial-4955eac76f4f
