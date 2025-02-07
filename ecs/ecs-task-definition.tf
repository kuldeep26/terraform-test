locals {
  envs = [
    {
      name  = "DB_API_Role_username"
      value = var.api_role_username
    },
    {
      name  = "DB_API_Role_password"
      value = var.api_role_password
    },
    {
      name  = "DB_INGESTION_Role_username"
      value = var.ingestion_role_username
    },
    {
      name  = "DB_INGESTION_Role_password"
      value = var.ingestor_role_password
    },
    {
      name  = "DB_INSIGHTS_Role_username"
      value = var.insights_role_username
    },
    {
      name  = "DB_INSIGHTS_Role_password"
      value = var.insights_role_password
    }
  ]
}

resource "aws_ecs_task_definition" "api_task_definition" {
  family                   = "test-api"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::730335559458:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  task_role_arn            = "arn:aws:iam::730335559458:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  skip_destroy             = true

  container_definitions = jsonencode([
    {
      name        = "test-api"
      environment = local.envs
      dockerLabels = {
        Image_Digest = "https://udhdkkdldllkd@12342111"
        Image_Tag    = "1.5.5"
      }
      image       = "730335559458.dkr.ecr.us-east-1.amazonaws.com/test:1.5.5"
      mountPoints = []
      essential   = true
      command = [
        "--strategy=AWS",
        "--db-role-name=${var.api_role_username}",
        "--db-role-password=${var.api_role_password}"
      ]
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "ecs"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      volumesFrom = []
    }
  ])

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}