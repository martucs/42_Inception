#!/bin/bash
set -e

# --- Ensure MariaDB listens on all interfaces ---
echo "🛠️ Configuring MariaDB bind-address..."
cat > /etc/mysql/mariadb.conf.d/99-bind.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF
echo "✅ bind-address set to 0.0.0.0"

# --- Start MariaDB as PID 1 in background ---
echo "🛠️ Starting MariaDB as PID 1..."
mysqld &

MYSQL_PID=$!

# --- Wait until MariaDB accepts root login ---
echo "⏳ Waiting for MariaDB to accept root connections..."
until mariadb -u root -e "SELECT 1" &>/dev/null; do
    sleep 1
done

# --- Initialize system tables if empty ---
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🛠️ Initializing system tables..."
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql
fi

# --- Ensure root password and WordPress user exist ---
echo "🛠️ Setting root password and creating WordPress database/user..."
mariadb -u root <<-EOSQL
    -- Root user
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;

    -- WordPress database and user
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

    FLUSH PRIVILEGES;
EOSQL

# --- Verify TCP socket readiness ---
echo "✅ MariaDB fully ready, testing TCP socket..."
until mariadb-admin ping -u root -p"${MYSQL_ROOT_PASSWORD}" --host=localhost &>/dev/null; do
    echo "⏳ Waiting for local socket to be ready..."
    sleep 1
done
echo "✅ MariaDB TCP socket ready."

echo "✅ MariaDB is fully ready."

# --- Bring PID 1 process to foreground ---
wait $MYSQL_PID
