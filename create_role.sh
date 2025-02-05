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
echo "Creating role cpm_api role..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE $API_ROLE_NAME WITH PASSWORD '$API_ROLE_PASSWORD' LOGIN;"
echo "Creating role scp-insights role..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE scp-insights WITH PASSWORD '$SCP_ROLE_PASSWORD' LOGIN;"

echo "Granting CONNECT privilege to scp-insights on database $DB_NAME..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "GRANT CONNECT ON DATABASE \"$DB_NAME\" TO \"$SCP_ROLE_NAME\";"

# List all roles
echo "Listing all roles:"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\du"

echo "Role creation and privilege granting completed successfully."
