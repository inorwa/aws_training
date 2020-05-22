AWS Training:

prerequisites:
- account on AWS
https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/
https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc
https://awscli.amazonaws.com/AWSCLIV2.msi

AWS Basics- introduction:

Amazon Web Services (AWS) is the cloud platform
https://www.youtube.com/watch?v=a9__D53WsUs
https://www.youtube.com/watch?v=dH0yz-Osy54

https://aws.amazon.com/about-aws/global-infrastructure/?pg=WIAWS

Regions
AWS has the concept of a Region, which is a physical location around the world where we cluster data centers. We call each group of logical data centers an Availability Zone. Each AWS Region consists of multiple, isolated, and physically separate AZ's within a geographic area. Unlike other cloud providers, who often define a region as a single data center, the multiple AZ design of every AWS Region offers advantages for customers. Each AZ has independent power, cooling, and physical security and is connected via redundant, ultra-low-latency networks. AWS customers focused on high availability can design their applications to run in multiple AZ's to achieve even greater fault-tolerance. AWS infrastructure Regions meet the highest levels of security, compliance, and data protection.

AWS provides a more extensive global footprint than any other cloud provider, and to support its global footprint and ensure customers are served across the world, AWS opens new Regions rapidly. AWS maintains multiple geographic Regions, including Regions in North America, South America, Europe, China, Asia Pacific, and the Middle East.

Availability Zones
An Availability Zone (AZ) is one or more discrete data centers with redundant power, networking, and connectivity in an AWS Region. AZ’s give customers the ability to operate production applications and databases that are more highly available, fault tolerant, and scalable than would be possible from a single data center. All AZ’s in an AWS Region are interconnected with high-bandwidth, low-latency networking, over fully redundant, dedicated metro fiber providing high-throughput, low-latency networking between AZ’s. All traffic between AZ’s is encrypted. The network performance is sufficient to accomplish synchronous replication between AZ’s. AZ’s make partitioning applications for high availability easy. If an application is partitioned across AZ’s, companies are better isolated and protected from issues such as power outages, lightning strikes, tornadoes, earthquakes, and more. AZ’s are physically separated by a meaningful distance, many kilometers, from any other AZ, although all are within 100 km (60 miles) of each other.

Services
AWS offers a broad set of global cloud-based products including compute, storage, database, analytics, networking, machine learning and AI, mobile, developer tools, IoT, security, enterprise applications, and much more. Our general policy is to deliver AWS services, features and instance types to all AWS Regions within 12 months of general availability, based on a variety of factors such as customer demand, latency, data sovereignty and other factors. Customers can share their interest for local region delivery, request service roadmap information, or gain insight on service interdependency (under NDA) by contacting your AWS sales representative. Due to the nature of the service, some AWS services are delivered globally rather than regionally, such as Amazon Route 53, Amazon Chime, Amazon WorkDocs, Amazon WorkMail, Amazon WorkSpaces, Amazon WorkLink.

- security
	https://aws.amazon.com/products/security/

	Prevent
	Define user permissions and identities, infrastructure protection and data protection measures for a smooth and planned AWS adoption strategy.

	Detect
	Gain visibility into your organization’s security posture with logging and monitoring services. Ingest this information into a scalable platform for event management, testing, and auditing.

	Respond
	Automated incident response and recovery to help shift the primary focus of security teams from response to analyzing root cause.

	Remediate
	Leverage event driven automation to quickly remediate and secure your AWS environment in near real-time.

	- IAM - Securely manage access to services and resources
	- Cognito - Identity management for your apps

- networking
	https://aws.amazon.com/products/networking/
	https://www.youtube.com/watch?v=hiKPPy584Mg
	https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
	
	- VPC - Resource isolation
	- ALB - Load balancing

- compute
	https://aws.amazon.com/products/compute/
	
	- EC2 - Secure and resizable compute capacity (virtual servers) in the cloud
	- ECS - Highly secure, reliable, and scalable way to run containers
	- Fargate - Serverless compute for containers
	- Lambda - Run code without thinking about servers. Pay only for the compute time you consume

- storage/database
	https://aws.amazon.com/products/storage/
	
	- S3 - A scalable, durable platform to make data accessible from any Internet location, for user-generated content, active archive, serverless computing, Big Data storage or backup and recovery
	- RDS - Relational, Traditional applications, ERP, CRM, e-commerce
	- DynamoDB - Key-value, High-traffic web apps, e-commerce systems, gaming applications

- cost optimization
	https://aws.amazon.com/pricing/
	https://aws.amazon.com/aws-cost-management/
	https://calculator.s3.amazonaws.com/index.html
	https://calculator.aws/#/
	
	- billing
	- best fit for task

Infrastructure As Code
- Console - https://aws.amazon.com/console/
- Cloud Formation - https://aws.amazon.com/cloudformation/
- Terraform - https://www.terraform.io/ https://www.youtube.com/watch?v=2zpHcrXGj4Q&list=PL0yQYCnvTmOvNvjaPXMIFx1SFJerk0pqv
- SDK - https://aws.amazon.com/sdk-for-node-js/

Project:
	- ECS Fargate application
	- storage to store data
	- frontend, producer, stock, consumer
		
-------------------------------------------------------------------------------
EC2

How to install nodejs on EC2 amazon linux
sudo yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -
sudo yum install -y nodejs

Key pair must exists (cannot be created by CF or TF)

-------------------------------------------------------------------------------
Docker

Delete all docker things
docker system prune -a

Run docker image
docker run -d -p 3000:3000 docker.pkg.github.com/mpetla/aws_training/frontend:latest
docker exec frontend -it /ash

-------------------------------------------------------------------------------
Github

Github as Docker repository

cat ~/TOKEN.txt | docker login docker.pkg.github.com -u mpetla@gmail.com --password-stdin
docker tag frontend docker.pkg.github.com/mpetla/aws_training/frontend:latest
docker build -t docker.pkg.github.com/mpetla/aws_training/frontend:latest .
docker push docker.pkg.github.com/mpetla/aws_training/frontend:latest
docker pull docker.pkg.github.com/mpetla/aws_training/frontend:latest

-------------------------------------------------------------------------------
Terraform

terraform init
terraform validate
terraform plan -state=training.tfstate -out=plan
terraform apply -state=training.tfstate "plan"
terraform destroy -state=training.tfstate

https://www.terraform.io/downloads.html

-------------------------------------------------------------------------------
