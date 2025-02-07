#!/bin/bash

set -e  # Exit immediately if a command fails

# Fetch RDS password from AWS Secrets Manager
export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id rds/master/password --query "SecretString" --output text | jq -r .password)

# Ensure the password is set
if [[ -z "$PGPASSWORD" ]]; then
  echo "Error: database password not recieved."
  exit 1
fi
# Function to check if DB role exists
role_exists() {
  local role_name=$1
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$role_name';" | grep -q 1
}
# Create API role if it doesn't exist
if role_exists "$API_ROLE_NAME"; then
  echo "Role $API_ROLE_NAME already exists, skipping creation."
else
  echo "Creating role $API_ROLE_NAME..."
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE $API_ROLE_NAME WITH PASSWORD '$API_ROLE_PASSWORD' LOGIN;"
fi
# Create Ingestor role if it doesn't exist
if role_exists "$INGESTOR_ROLE"; then
  echo "Role $INGESTOR_ROLE already exists, skipping creation."
else
  echo "Creating role $INGESTOR_ROLE..."
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE $INGESTOR_ROLE WITH PASSWORD '$INGESTOR_ROLE_PASSWORD' LOGIN;"
fi
# Create Insights role if it doesn't exist
if role_exists "$INSIGHTS_ROLE_NAME"; then
  echo "Role $INSIGHTS_ROLE_NAME already exists, skipping creation."
else
  echo "Creating role $INSIGHTS_ROLE_NAME..."
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE $INSIGHTS_ROLE_NAME WITH PASSWORD '$INSIGHTS_ROLE_PASSWORD' LOGIN;"
  # Grant access
  echo "Granting CONNECT privilege to $INSIGHTS_ROLE_NAME on database $DB_NAME..."
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "GRANT CONNECT ON DATABASE \"$DB_NAME\" TO \"$INSIGHTS_ROLE_NAME\";"
fi
# List all roles
echo "Listing all roles:"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\du"
echo "Role creation and privilege granting completed successfully."
