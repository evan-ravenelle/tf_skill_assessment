terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# AWS Container Module
# Deploys a containerized application on AWS using ECS Fargate.
resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-ecs-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = jsonencode([
    {
      name      = "app"
      image     = var.container_image
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.environment}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_id]
    assign_public_ip = false

  }
}