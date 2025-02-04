#!/bin/bash

set -e  # Exit on any error

# Fetch RDS password from AWS Secrets Manager
PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id rds/master/password --query "SecretString" --output text | jq -r .password)

# Create the role in PostgreSQL
echo "Creating role ibm_ingestor..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE ibm_ingestor WITH PASSWORD '$PGPASSWORD' LOGIN;"

# List all roles
echo "Listing all roles:"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\du"

echo "Role creation completed successfully."
