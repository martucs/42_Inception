#!/bin/bash
set -e

# --- Load environment variables manually ---
if [ -f /root/.env ]; then
    export $(grep -v '^#' /root/.env | xargs)
else
    echo "⚠️  .env file not found at /root/.env"
fi

echo "✅ Loaded environment variables:"
echo "  DB: $MYSQL_DATABASE"
echo "  USER: $MYSQL_USER"

# --- Start MariaDB in the background ---
mysqld_safe &

# Wait until MariaDB is ready
until mariadb -u root -e "SELECT 1" &> /dev/null; do
    echo "⏳ Waiting for MariaDB to start..."
    sleep 1
done

# --- Initialization SQL ---
mariadb -u root <<-EOSQL
  CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
  CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
  GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
  FLUSH PRIVILEGES;
EOSQL

echo "✅ MariaDB initialized successfully."

# Stop background mysqld
mysqladmin -u root shutdown

exec mysqld_safe
