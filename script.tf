resource "random_string" "api_role_api_password" {
  length  = 10
  special = false
}

resource "random_string" "insight_role_api_password" {
  length  = 10
  special = false
}

resource "aws_secretsmanager_secret" "api_role_password" {
  name        = "rds/api/role/password"
  description = "API Role password for RDS"
}

resource "aws_secretsmanager_secret_version" "api_role_password_version" {
  secret_id = aws_secretsmanager_secret.api_role_password.id
  secret_string = jsonencode({
    role_name = "cpm_api",
    password  = "${random_string.api_role_api_password.result}"
  })
}

### SCP Role secret ###
resource "aws_secretsmanager_secret" "scp_role_password" {
  name        = "rds/scp/role/password"
  description = "Insight Role password for RDS"
}

resource "aws_secretsmanager_secret_version" "scp_role_password_version" {
  secret_id = aws_secretsmanager_secret.scp_role_password.id
  secret_string = jsonencode({
    role_name = "scp-insights",
    password  = "${random_string.insight_role_api_password.result}"
  })
}

resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds/master/password"
  description = "RDS password for RDS"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = "test",
    password = "must_be_eight_characters"
  })
}

resource "null_resource" "create_db_role" {
  depends_on = [aws_rds_cluster.example, aws_rds_cluster_instance.example, aws_secretsmanager_secret_version.rds_role_password_version]

  provisioner "local-exec" {
    command = "/bin/bash create_role.sh"

    environment = {
      DB_HOST           = "${aws_rds_cluster.example.endpoint}"
      DB_USER           = "test" # Change as needed
      DB_NAME           = "test" # Change as needed
      API_ROLE_PASSWORD = "${jsondecode(aws_secretsmanager_secret_version.api_role_password_version.secret_string).password}"
      SCP_ROLE_PASSWORD = "${jsondecode(aws_secretsmanager_secret_version.scp_role_password_version.secret_string).password}"
      API_ROLE_NAME     = "cpm_api"
      SCP_ROLE_NAME     = "scp-insights"
    }
  }
}




