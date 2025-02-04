resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds/master/password"
  description = "Master password for RDS"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = "master",
    password = "must_be_eight_characters"
  })
}

resource "null_resource" "create_db_role" {
  depends_on = [aws_rds_cluster.example, aws_rds_cluster_instance.example]

  provisioner "local-exec" {
    command = <<EOT
      PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id rds/master/password --query 'SecretString' --output text | jq -r .password) psql -h ${aws_rds_cluster.example.endpoint} -U master -d postgres -c "CREATE ROLE ibm_api WITH PASSWORD 'must_be_eight_characters' LOGIN;"
    EOT
  }
}
