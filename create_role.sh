#!/bin/bash

set -e  # Exit immediately if a command fails

# Fetch RDS password from AWS Secrets Manager
export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id rds/master/password --query "SecretString" --output text | jq -r .password)

# Ensure the password is set
if [[ -z "$PGPASSWORD" ]]; then
  echo "Error: Failed to retrieve database password from Secrets Manager."
  exit 1
fi

# Create the role in PostgreSQL
echo "Creating role ibm_ingestor..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE ibm_ingestor_api WITH PASSWORD '$PGPASSWORD' LOGIN;"

# List all roles
echo "Listing all roles:"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\du"

echo "Role creation completed successfully."
