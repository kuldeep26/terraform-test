locals {
  ingress_cidr = ["0.0.0.0/0"]
}

resource "aws_rds_cluster" "example" {
  cluster_identifier              = "example"
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = "14.10"
  vpc_security_group_ids          = [aws_security_group.security_group.id]
  database_name                   = "test"
  master_username                 = "test"
  master_password                 = "must_be_eight_characters"
  storage_encrypted               = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.name
  availability_zones              = ["us-east-1a", "us-east-1b"]
  skip_final_snapshot             = true

  serverlessv2_scaling_configuration {
    max_capacity             = 1.0
    min_capacity             = 0.0
    seconds_until_auto_pause = 3600
  }

  lifecycle {

    ignore_changes = [
      tags,
      availability_zones,
      cluster_members,
      engine_version,
      snapshot_identifier,
      final_snapshot_identifier,
      iam_database_authentication_enabled
    ]
  }
}

resource "aws_rds_cluster_instance" "example" {
  cluster_identifier      = aws_rds_cluster.example.id
  engine                  = aws_rds_cluster.example.engine
  engine_version          = aws_rds_cluster.example.engine_version
  db_parameter_group_name = aws_db_parameter_group.parameter_group.name
  instance_class          = "db.t3.medium"
  publicly_accessible     = true

  lifecycle {
    ignore_changes = [
      engine_version,
      tags
    ]
  }
}

resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  family = "aurora-postgresql14"
  name   = "test"
}

resource "aws_db_parameter_group" "parameter_group" {
  family = "aurora-postgresql14"
  name   = "test"
}

resource "aws_db_subnet_group" "subnet_group" {
  name        = "db-subnet"
  description = "Subnet groups for RDS with Private subnet ids"
  subnet_ids  = ["subnet-011f1bd1ebafaf2aa", "subnet-0062533b0e05b0700"]
}

resource "aws_security_group" "security_group" {
  name   = "rds-security-group"
  vpc_id = "vpc-097d46761a7957650"

  dynamic "ingress" {
    for_each = toset(local.ingress_cidr)
    content {
      description     = "All incoming traffic to db for port 5432"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      cidr_blocks     = substr(ingress.key, 0, 2) == "pl" ? [] : [ingress.key]
      prefix_list_ids = substr(ingress.key, 0, 2) == "pl" ? [ingress.key] : []
    }
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}
