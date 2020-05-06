locals {
  tags = {
    Id = "training"
    Name = "training"
  }
  region = "eu-west-1"
  az1a   = "eu-west-1a"
  az1b   = "eu-west-1b"
}

provider "aws" {
  version = "~> 2.0"
  region  = local.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = local.tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = local.tags
}

//nat gateway
resource "aws_eip" "nat_gateway_ip_az1a" {
  vpc = true

  tags = merge(local.tags, { Name = "training az1a" })
}

resource "aws_nat_gateway" "nat_gateway_az1a" {
  allocation_id = aws_eip.nat_gateway_ip_az1a.id
  subnet_id     = aws_subnet.public_subnet_az1a.id

  tags = merge(local.tags, { Name = "training az1a" })
}

resource "aws_eip" "nat_gateway_ip_az1b" {
  vpc = true

  tags = merge(local.tags, { Name = "training az1b" })
}

resource "aws_nat_gateway" "nat_gateway_az1b" {
  allocation_id = aws_eip.nat_gateway_ip_az1b.id
  subnet_id     = aws_subnet.public_subnet_az1b.id

  tags = merge(local.tags, { Name = "training az1b" })
}

//public subnet
resource "aws_subnet" "public_subnet_az1a" {
  cidr_block              = "10.0.1.0/28"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.az1a
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "training public az1a" })
}

resource "aws_subnet" "public_subnet_az1b" {
  cidr_block              = "10.0.1.16/28"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.az1b
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "training public az1b" })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "training public" })
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_route_table_association_az1a" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_az1a.id
}

resource "aws_route_table_association" "public_route_table_association_az1b" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_az1b.id
}

resource "aws_main_route_table_association" "public_main_route_table_association" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.public_route_table.id
}

//private subnet
resource "aws_subnet" "private_subnet_az1a" {
  cidr_block              = "10.0.2.0/28"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.az1a
  map_public_ip_on_launch = false

  tags = merge(local.tags, { Name = "training private az1a" })
}

resource "aws_subnet" "private_subnet_az1b" {
  cidr_block              = "10.0.2.16/28"
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.az1b
  map_public_ip_on_launch = false

  tags = merge(local.tags, { Name = "training private az1b" })
}

resource "aws_route_table" "private_route_table_az1a" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "training private az1a" })
}

resource "aws_route" "private_route_az1a" {
  route_table_id         = aws_route_table.private_route_table_az1a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_az1a.id
}

resource "aws_route_table_association" "private_route_table_association_az1a" {
  route_table_id = aws_route_table.private_route_table_az1a.id
  subnet_id      = aws_subnet.private_subnet_az1a.id
}

resource "aws_route_table" "private_route_table_az1b" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "training private az1b" })
}

resource "aws_route" "private_route_az1b" {
  route_table_id         = aws_route_table.private_route_table_az1b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_az1b.id
}

resource "aws_route_table_association" "private_route_table_association_az1b" {
  route_table_id = aws_route_table.private_route_table_az1b.id
  subnet_id      = aws_subnet.private_subnet_az1b.id
}

//load balancer
resource "aws_security_group" "application_load_balancer_security_group" {
  name        = "application-load-balancer-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.vpc.id
  tags        = local.tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "application_load_balancer" {
  name                       = "application-load-balancer"
  internal                   = false
  load_balancer_type         = "application"
  idle_timeout               = 30
  enable_deletion_protection = false
  tags                       = local.tags
  security_groups = [
    aws_security_group.application_load_balancer_security_group.id
  ]
  subnets = [
    aws_subnet.public_subnet_az1a.id,
    aws_subnet.public_subnet_az1b.id
  ]
}

resource "aws_alb_target_group" "frontend_target_group" {
  name        = "frontend-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  tags        = local.tags

  health_check {
    interval            = 300
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.frontend_target_group.arn
  }
}

//cluster
resource "aws_security_group" "cluster_security_group" {
  name        = "cluster-security-group"
  description = "Security group for Fargate Cluster"
  vpc_id      = aws_vpc.vpc.id
  tags        = local.tags

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_secretsmanager_secret" "artifactory_secret" {
  name                    = "artifactory_secret"
  description             = "Secret for artifactory"
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "secret_value" {
  secret_id     = aws_secretsmanager_secret.artifactory_secret.id
  secret_string = var.artifactory_secret
  depends_on    = [aws_secretsmanager_secret.artifactory_secret]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_add_secrets_manager" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_add_logs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_service_discovery_private_dns_namespace" "service_discovery_dns" {
  name        = "training"
  vpc         = aws_vpc.vpc.id
  description = "DNS for cluster networking"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name  = "training"
  tags  = local.tags
}

resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
  tags = local.tags
}

module "frontend" {
  source = "./ecs_service"

  service_discovery_name      = "frontend"
  service_discovery_dns_id    = aws_service_discovery_private_dns_namespace.service_discovery_dns.id
  task_definition_family      = "frontend"
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  tags                        = local.tags
  container_name              = "frontend"
  docker_image                = "docker.pkg.github.com/mpetla/aws_training/frontend:latest"
  container_port              = 3000
  host_port                   = 3000
  artifactory_secret_arn      = aws_secretsmanager_secret.artifactory_secret.arn
  log_group_id                = aws_cloudwatch_log_group.log_group.id
  region                      = local.region
  log_prefix                  = "frontend"
  environment_variables       = <<ENVIRONMENT_VARIABLES
[
  { "name": "PRODUCER_API", "value": "http://producer.training:3001" },
  { "name": "CONSUMER_API", "value": "http://consumer.training:3002" },
  { "name": "STOCK_API",    "value": "http://stock.training:3003" }
]
ENVIRONMENT_VARIABLES
  service_depends_on          = aws_alb_listener.listener
  service_name                = "frontend"
  cluster_arn                 = aws_ecs_cluster.cluster.arn
  subnets                     = [
    aws_subnet.private_subnet_az1a.id,
    aws_subnet.private_subnet_az1b.id
  ]
  security_groups             = [
    aws_security_group.cluster_security_group.id
  ]
  assign_public_ip            = true

  load_balancers = [
    {
      target_group_arn = aws_alb_target_group.frontend_target_group.arn
      container_port   = 3000
      container_name   = "frontend"
    }
  ]
}

module "producer" {
  source = "./ecs_service"

  service_discovery_name      = "producer"
  service_discovery_dns_id    = aws_service_discovery_private_dns_namespace.service_discovery_dns.id
  task_definition_family      = "producer"
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  tags                        = local.tags
  container_name              = "producer"
  docker_image                = "docker.pkg.github.com/mpetla/aws_training/producer:latest"
  container_port              = 3001
  host_port                   = 3001
  artifactory_secret_arn      = aws_secretsmanager_secret.artifactory_secret.arn
  log_group_id                = aws_cloudwatch_log_group.log_group.id
  region                      = local.region
  log_prefix                  = "producer"
  environment_variables       = <<ENVIRONMENT_VARIABLES
[
  { "name": "STOCK_HOST", "value": "http://stock.training:3003" }
]
ENVIRONMENT_VARIABLES
  service_depends_on          = null
  service_name                = "producer"
  cluster_arn                 = aws_ecs_cluster.cluster.arn
  subnets                     = [
    aws_subnet.private_subnet_az1a.id,
    aws_subnet.private_subnet_az1b.id
  ]
  security_groups             = [
    aws_security_group.cluster_security_group.id
  ]
  assign_public_ip            = false
  load_balancers              = []
}

module "consumer" {
  source = "./ecs_service"

  service_discovery_name      = "consumer"
  service_discovery_dns_id    = aws_service_discovery_private_dns_namespace.service_discovery_dns.id
  task_definition_family      = "consumer"
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  tags                        = local.tags
  container_name              = "consumer"
  docker_image                = "docker.pkg.github.com/mpetla/aws_training/consumer:latest"
  container_port              = 3002
  host_port                   = 3002
  artifactory_secret_arn      = aws_secretsmanager_secret.artifactory_secret.arn
  log_group_id                = aws_cloudwatch_log_group.log_group.id
  region                      = local.region
  log_prefix                  = "consumer"
  environment_variables       = <<ENVIRONMENT_VARIABLES
[
  { "name": "STOCK_HOST", "value": "http://stock.training:3003" }
]
ENVIRONMENT_VARIABLES
  service_depends_on          = null
  service_name                = "consumer"
  cluster_arn                 = aws_ecs_cluster.cluster.arn
  subnets                     = [
    aws_subnet.private_subnet_az1a.id,
    aws_subnet.private_subnet_az1b.id
  ]
  security_groups             = [
    aws_security_group.cluster_security_group.id
  ]
  assign_public_ip            = false
  load_balancers              = []
}

module "stock" {
  source = "./ecs_service"

  service_discovery_name      = "stock"
  service_discovery_dns_id    = aws_service_discovery_private_dns_namespace.service_discovery_dns.id
  task_definition_family      = "stock"
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  tags                        = local.tags
  container_name              = "stock"
  docker_image                = "docker.pkg.github.com/mpetla/aws_training/stock:latest"
  container_port              = 3003
  host_port                   = 3003
  artifactory_secret_arn      = aws_secretsmanager_secret.artifactory_secret.arn
  log_group_id                = aws_cloudwatch_log_group.log_group.id
  region                      = local.region
  log_prefix                  = "stock"
  environment_variables       = <<ENVIRONMENT_VARIABLES
[
  { "name": "MODE", "value": "aws" }
]
ENVIRONMENT_VARIABLES
  service_depends_on          = null
  service_name                = "stock"
  cluster_arn                 = aws_ecs_cluster.cluster.arn
  subnets                     = [
    aws_subnet.private_subnet_az1a.id,
    aws_subnet.private_subnet_az1b.id
  ]
  security_groups             = [
    aws_security_group.cluster_security_group.id
  ]
  assign_public_ip            = false
  load_balancers              = []
}

//dynamodb
//table
resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "training"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "stock"

  attribute {
    name = "stock"
    type = "S"
  }

  tags = local.tags
}

//IAM
resource "aws_iam_role_policy_attachment" "ecs_execution_role_dynamodb" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.ecs_task_execution_role.name
}
