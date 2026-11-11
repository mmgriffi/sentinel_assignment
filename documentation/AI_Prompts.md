# AI prompts

### These prompts were all run against Google Gemini (I checked , they do not provide a version number)

========================================================================================
## Sentinel Structure

I'm trying to structure my terraform / sentinel folders and files. I only have a Terraform free account (limited 1 policy) . 
This is the GitHub repository structure I was hoping for.

<repo>
├───sentinel
│   |
│   |___ allowed-providers.sentinel
|   |___ network.sentinel
| 
├───terraform
|   |  
|   |___main.tf
|     
|___ sentinel.hcl

I will wish to test a number of different terraform scripts against single policy definitions (by command line I guess )
Perhaps "sentinel apply -config=sentinel.hcl sentinel/allowed-providers.sentinel"  (and switch other .sentinel files as required) 

Is this feasible ? 
========================================================================================
## Sentinel CLI
Show me how to run a sentinel test using the CLI . 
Use the attached "allowed-providers.sentinel" file, the passing file is "pass-correct-provider.json" and failing file "fail-correct-provider.json"
Here is the planned structure of my repo

<repo>
├───sentinel
│   |
│   |___ allowed-providers.sentinel
|   |___ network.sentinel
| 
├───terraform
|   |  
|   |___main.tf
|
|
|____tests
|  |
|  |-allowed-providers
|      |
|      |-pass-correct-provider.json
|      |-fail-correct-provider.json
|     
|___ sentinel.hcl

Tasks:
Verify the structure (folder names/ filenames)
Provide the commands to run the tests.

I have used this structure so far... does this look correct ? 
C:.
|
├───documentation
├───sentinel
│   └───test
│       └───allowed-providers
└──|─terraform
|   |__main.tf
|   |_providers.tf  
|   |_network.tf
|   |_versions.tf
|
|
|-sentinel.hcl

Where will I run terraform init /plan (inside the terraform folder ? ) 

========================================================================================
## Create policy and test
Please review the attached terraform files, and sentinel scripts.
(I provided network.tf, main.tf,providers.tf, versions.tf, variables.tf )

The terraform files create an environment (network, compute and storage) and I wish to use sentinel to validate that the enviroment will the policy.   

Constraints
The terrafrom files are in <root>\terraform folder, sentinel files are in <root>\sentinel and pass/fail json files are in <root>\sentinel\test\allowed-providers. The sentinel.hcl file is in the repository root.  
I will add additional policies later. 

Task
I will start with a policy check on providers.
(1) Is this approach correct for sentinel/terraform ? 
(2) Based on the terraform scripts provide the steps I need to follow to validate the policy. 
(3) Outline the steps I need to take to expand this to additional policies. Next might be enforcing specific EC2 instance types. 

========================================================================================
## Mock data

I have defined an AWS infrastructure project in terraform with the structure shown
|
|--terraform
   |
   |-main.tf
   |-network.tf
   |-providers.tf
   |-versions.tf
   |-outputs.tf
   |-variables.tf

The project contains a VPC network with 2 subnets (1 private, 1 public) . 
The compute layer is a single EC2 instance in the public subnet, data is a single node RDS SQL database in the private subnet. Additional storage is a S3 bucket. I have created the IAM profile and policy to allow the EC2 instance access the storage. 

I then created a plan and binary output, and generated a json data
terraform show -json sentinelTF.tfplan > mock-data.json.

I wish to create sentinel tests which I can test from sentinel CLI for the following

allowed-providers.sentinel (note we have already the script for this category and ran sentinel test )
instance_type.sentinel
network.sentinel
sovereignty.sentinel
encryption.sentinel. 

Tasks
Show me how to find and extract the data I need from the mock-data.json file for each of these sentinel files. 
How to generate  pass / fail test files to match each category.

Do you need additional data/files ? 
========================================================================================

#  Using Terrafrom online.
I have a Terraform definition is on GitHub, I have not included any .hcl or .sentinel files yet. 
Task :  Can you list the steps to connect my terraform online workspace to the repository and generate a plan / mock data. 
I will then need to download the mock data to test some sentinel policies locally via CLI.

===========================================================================================

I've been using sentinel to test policies at the command line with mock data generated from a terraform plan. 

Can you describe a terraform / sentinel scenario  where a team would create policies and ensure any AWS infrastructure 
changes are checked against that policy and they are effectively prevented from implementing those changes in a production scenario. 
Running CLI checks against downloaded mock data is not enforcing the policy.

I had the region variable in terraform.tfvars , with it's definition in variables.tf (this had a default). When I ran it with the change in tfvars file the run still passed which is not what I expected. 
Should the sentinel.hcl file reference mock data anymore or does that matter ?

if I remove the reference to the mock data, change tfvars and run on the terraform UI in plan mode, 
I should see a rule violation if I'm trying to set a region outside the policy (eu-west-1)
================================
### Network policies

can you review the attached terraform network.tf file, it create an AWS VPC with subnets and has 
specific ports open for SSH, SQL access. 
Task : create a sentinel policy that will enforce restrictions on
 unbound SSH access, ensure only the public subnet is accessable from outside 
the VPC and the db subnet only allows port 3306 inbound access.

For the .sentinel files, is it possible to use variables in an seperate file,
hard coding the values does make it harder to maintain.

### IAM / AWS restrictions.
is is possible to create an AWS iam user that can only access a specific region ?
I've created the user + attached it to a policy containing the above as an inline policy. To test, how do I add permissions to (for example) create a S3 bucket ?
can we expand on the permissions. I want to allow this account add VPC, subnet components , s3 bucket, ec2 instance and rds database, but as before restricted to eu-west-1.
(this did lead off in a tangent... while I could create a IAM user, apply policies to a group, in practice using this method ran into lots of 
problems - while I could grant it permissions to create EC2 , VPC etc , a restricted user ran into other problems listing/reading some components)
Looks like this should be planned at the Organization level with policies there, rather than groups.AWSTemplateFormatVersion: "2010-09-09"

##### Expanding instance-type.sentinel
Can you review this terraform sentinel policy for the EC2 instance ,
I would like to expand it to check that IMDSv2 is set and that encrypted EBS storage is used.

##############The changes to the terraform EC2 create block are on this prompt :  
Review this terraform block to create an ec2 instance, change it to enable imdsv2 and ensure the root and block devices are encrypted 

"# Create EC2 Instance
resource "aws_instance" "ec2_server" {
  ami                    = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_server.id]
  key_name               = var.keypair"
  
## additonal mock structures for sentinel test
Can you provide pass and fail json mock data files to test this policy (instance_type.sentinel)
