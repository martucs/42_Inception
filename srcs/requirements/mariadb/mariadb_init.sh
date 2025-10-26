#!/bin/bash
set -e

# --- Ensure MariaDB listens on all interfaces ---
echo "🛠️ Configuring MariaDB bind-address..."
cat > /etc/mysql/mariadb.conf.d/99-bind.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF
echo "✅ bind-address set to 0.0.0.0"

# --- Initialize MariaDB data directory if empty ---
if [ ! -f "/var/lib/mysql/mysql/user.frm" ]; then
    echo "🛠️ Initializing system tables..."
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql
fi

# --- Start MariaDB in background ---
echo "🛠️ Starting MariaDB..."
mysqld &
MYSQL_PID=$!

# --- Wait for MariaDB socket to be ready ---
until mariadb -u root -sse "SELECT 1" &>/dev/null; do
    echo "⏳ Waiting for MariaDB to be ready..."
    sleep 1
done

# --- Set root password only if not already set ---
ROOT_PASSWORD_SET=$(mariadb -u root -sse "SELECT 1" 2>/dev/null || true)
if [ -z "$ROOT_PASSWORD_SET" ]; then
    echo "🛠️ Setting root password..."
    mariadb -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
EOSQL
    echo "✅ Root password set"
else
    echo "✅ Root password already configured"
fi

# --- Check if WordPress database exists ---
EXISTING_DB=$(mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -sse "SHOW DATABASES LIKE '${MYSQL_DATABASE}'" || true)
if [ -z "$EXISTING_DB" ]; then
    echo "🛠️ Creating WordPress database and user..."
    mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL
    echo "✅ WordPress database and user created"
else
    echo "✅ WordPress database already exists, skipping creation"
fi

# --- Verify TCP socket readiness ---
echo "⏳ Checking TCP socket..."
until mariadb-admin ping -u root -p"${MYSQL_ROOT_PASSWORD}" --host=localhost &>/dev/null; do
    sleep 1
done
echo "✅ MariaDB TCP socket ready."

# --- Bring PID 1 process to foreground ---
wait $MYSQL_PID
