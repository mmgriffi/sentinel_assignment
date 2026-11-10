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
(there is no need for "depends" in this scenario)

I stood up the environment using Terraform apply and validatd some of the relevant aspects (all components in correct region, access between EC2 and RDS and S3 .. again , overkill)

## Sentinel.
- I created accounts on HCP Terraform and HCP Cloud (linking these 2 was promlematic and downloaded the sentinel binary file. )
- Followed assignment/Gemini on structing the sentinel files, test folders and content. 
- Created a project and workspace on terraform hcl and linked this github repository to it. 
- Created a run (plan only) which generated mock/test data to download. Extracted files and placed this in the terraform folder. [zipfile](/terraform/run-JvxYqKbp68aBDmy4-sentinel-mocks.tar.gz)
 


At this stage the .sentinel files  were not included in the repo.
- Gemini had given me the policy definition suitale for instance-type, soverignity and allowed-providers. 
  - With the mock data these pass. 
  - I was able to substitute instance types, regions that were not allowed in the .sentinel files and these failed/flagged as expected when executed via CLI 

   
## Generate 

https://app.terraform.io/app/atuIAC-terraform-mmgriffi-tf-org/workspaces


- Terraform Policy definitions only allow 1 hard enforcement so I needed to configure others as advisory.

|Policy Name|Details|Passing Image|Failing Image|Notes
|----|----|----|----|----|
|Sovergnity|limited to a single region "allowed_regions = ["eu-west-1"]"   |[Pass](/images/TerraformUI_Apply_Passed_Sovereignty.jpg)|[Fail](/images/TerraformUI_Apply_Failed_Sovereignty.jpg)|switch terrafrom.tfvars to aws_region = "us-east-1", commit changes to GitHub and re-trigger Terraform UI run|
|Instance-type|uses array of instance types "allowed_types = ["t3.micro", "t3.small","t2.micro"]", ensure ebs is encrypted and IMDSv2 is enabled||[Advisory](/images/TerraformUI_FailAdvisory_Instance-type.jpg)||


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
