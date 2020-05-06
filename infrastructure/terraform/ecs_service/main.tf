resource "aws_service_discovery_service" "discovery_service" {
  name = var.service_discovery_name

  dns_config {
    namespace_id = var.service_discovery_dns_id

    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.task_definition_family
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.ecs_task_execution_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  tags                     = var.tags

  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "${var.container_name}",
    "image": "${var.docker_image}",
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "protocol": "tcp",
        "hostPort": ${var.host_port}
      }
    ],
    "repositoryCredentials": {
      "credentialsParameter": "${var.artifactory_secret_arn}"
    },
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.log_group_id}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "${var.log_prefix}"
      }
    },
    "mountPoints": [],
    "volumesFrom": [],
    "environment": ${var.environment_variables}
  }
]
  TASK_DEFINITION
}

resource "aws_ecs_service" "service" {
  depends_on = [var.service_depends_on]

  name                = var.service_name
  cluster             = var.cluster_arn
  task_definition     = aws_ecs_task_definition.task_definition.arn
  launch_type         = "FARGATE"
  platform_version    = "LATEST"
  desired_count       = 1
  scheduling_strategy = "REPLICA"

  network_configuration {
    subnets = var.subnets
    security_groups = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  service_registries {
    registry_arn = aws_service_discovery_service.discovery_service.arn
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value["target_group_arn"]
      container_port   = load_balancer.value["container_port"]
      container_name   = load_balancer.value["container_name"]
    }
  }
}