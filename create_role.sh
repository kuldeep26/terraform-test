#!/bin/bash

set -e  # Exit immediately if a command fails

# Fetch RDS password from AWS Secrets Manager
export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id rds/master/password --query "SecretString" --output text | jq -r .password)

# Ensure the password is set
if [[ -z "$PGPASSWORD" ]]; then
  echo "Error: Failed to retrieve database password from Secrets Manager."
  exit 1
fi

# Function to check if a role exists
role_exists() {
  local role_name=$1
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$role_name';" | grep -q 1
}

# Create API role if it does not exist
if role_exists "$API_ROLE_NAME"; then
  echo "Role \"$API_ROLE_NAME\" already exists. Skipping creation."
else
  echo "Creating role \"$API_ROLE_NAME\"..."
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE \"$API_ROLE_NAME\" WITH PASSWORD '$API_ROLE_PASSWORD' LOGIN;"
fi

# Create SCP role if it does not exist
if role_exists "$SCP_ROLE_NAME"; then
  echo "Role \"$SCP_ROLE_NAME\" already exists. Skipping creation."
else
  echo "Creating role \"$SCP_ROLE_NAME\"..."
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "CREATE ROLE \"$SCP_ROLE_NAME\" WITH PASSWORD '$SCP_ROLE_PASSWORD' LOGIN;"
fi

# Grant CONNECT privilege to SCP role (only if it was just created)
if role_exists "$SCP_ROLE_NAME"; then
  echo "Granting CONNECT privilege to \"$SCP_ROLE_NAME\" on database \"$DB_NAME\"..."
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "GRANT CONNECT ON DATABASE \"$DB_NAME\" TO \"$SCP_ROLE_NAME\";"
fi

# List all roles
echo "Listing all roles:"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\du"

echo "Role creation and privilege granting completed successfully."
