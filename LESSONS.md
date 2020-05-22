AWS Basics, IAM, VPC, EC2

Topics:
- AWS Basics
- AWS Identity and Access Management (IAM) 
- Amazon Virtual Private Cloud (VPC)
- Amazon Elastic Compute Cloud (EC2)

What you will learn:
- how to create user and specific roles,
- how to login to console and cli,
- understand roles and policies, user security options

IAM and security:
1)  Create user training
2)  Create group Administrators, add policy Admin, add user to group
3)  Review policy
4)  Review role
5)  Review user security options

Networking:
1)  Create VPC - 10.0.0.0/16
2)  Create internet gateway
3)  Create public subnet - 10.0.0.0/28 - 11 hosts
4)  Create private subnet - 10.1.0.0/28 - 11 hosts
5)  Create public route table
6)  Create private route table
7)  Create key pair
8)  Create EC2 instance in public subnet (public IP), security group
9)  Create EC2 instance in private subnet (private IP), security group
10) SSH into public and private EC2
11) Change security groups setting, change route tables
12) Curl internet available service

Infrastructure as code, building applications

Topics:
- AWS Lambda, Amazon Elastic Container Service (ECS), Amazon EKS
- Infrastructure as code, (CloudFormation, Terraform, CLI, SDK)
- project

What you will learn:
- how to setup environment with CloudFormation
- how to setup environment with Terraform
- how to create project from scratch

Compute and containers:
1) Review EC2, Lambda
2) Review ECS, EKS

Infrastructure as code
1) Review console, CLI, SDK
2) Review CloudFormation, CDK
3) Review Terraform

Project with infrastructure in terraform:
- vpc
- two subnets (public, private)
- alb, routing
- fargate (cluster, task definition, service)
- dynamodb

https://devcloud.swcoe.ge.com/devspace/display/~212626796/AWS+Training

https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html
