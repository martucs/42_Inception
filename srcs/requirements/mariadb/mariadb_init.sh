#!/bin/bash
set -e

# Create bind config
cat > /etc/mysql/mariadb.conf.d/99-bind.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF

# Initialize DB if missing
if [ ! -d "/var/lib/mysql/mysql" ] || [ -z "$(ls -A /var/lib/mysql/mysql 2>/dev/null)" ]; then
    echo "Database directory empty — initializing..."
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql --skip-test-db
    DB_WAS_EMPTY=true
else
    DB_WAS_EMPTY=false
fi

# Start MariaDB safely in background
mysqld_safe &
pid="$!"

# Wait until ready
until mysqladmin ping --silent; do
  echo "Waiting for MariaDB to start..."
  sleep 1
done

if [ "$DB_WAS_EMPTY" = true ]; then
    echo "Configuring root and application users..."
    mysql -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL
fi

# Stop background process and relaunch in foreground
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "MariaDB setup complete. Starting foreground server..."
exec mysqld_safe
