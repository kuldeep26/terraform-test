output "api_role_password" {
  description = "API DB role password"
  value       = jsondecode(aws_secretsmanager_secret_version.api_role_password_version.secret_string).password
  sensitive   = true
}

output "insights_role_password" {
  description = "Insights DB role password"
  value       = jsondecode(aws_secretsmanager_secret_version.insights_role_password_version.secret_string).password
  sensitive   = true
}

output "ingestor_role_password" {
  description = "Ingestor DB role password"
  value       = jsondecode(aws_secretsmanager_secret_version.ingestion_role_password_version.secret_string).password
  sensitive   = true
}