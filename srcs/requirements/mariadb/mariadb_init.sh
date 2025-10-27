#!/bin/bash
set -e

# --- Configure MariaDB to listen on all interfaces ---
cat > /etc/mysql/mariadb.conf.d/99-bind.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF

# --- Initialize database directory if empty ---
if [ ! -f "/var/lib/mysql/mysql/user.frm" ]; then
    echo "Initializing system tables bc user.frm doesnt exist"
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql
    DB_WAS_EMPTY=true
else
    DB_WAS_EMPTY=false
fi

if [ "$DB_WAS_EMPTY" = true ]; then
	echo "Database was empty"
else
	echo "Database was NOT empty"
fi

# --- Start MariaDB in background ---
echo "🛠️ Starting MariaDB..."
mysqld &
MYSQL_PID=$!

# --- Wait for MariaDB to be ready (dynamic auth) ---
echo "Waiting for MariaDB to be ready..."
for i in {1..60}; do
    if mariadb -u root -sse "SELECT 1" &>/dev/null; then
        ROOT_AUTH="-u root"
        break
    fi
    if mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -sse "SELECT 1" &>/dev/null; then
        ROOT_AUTH="-u root -p${MYSQL_ROOT_PASSWORD}"
        break
    fi
    sleep 1
done
echo "✅ MariaDB ready for connections"

# --- Set root password only on first boot ---
if [ "$DB_WAS_EMPTY" = true ]; then
    echo "Setting root password..."
    mariadb $ROOT_AUTH <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
EOSQL
    echo "✅ Root password set"
fi

# --- Create WordPress database and user if missing ---
EXISTING_DB=$(mariadb $ROOT_AUTH -sse "SHOW DATABASES LIKE '${MYSQL_DATABASE}'")
if [ -z "$EXISTING_DB" ]; then
    echo "Creating WordPress database and user..."
    mariadb $ROOT_AUTH <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL
    echo "✅ WordPress database and user created"
else
    echo "✅ WordPress database already exists, skipping creation"
fi

# --- Check TCP readiness ---
echo "⏳ Checking TCP socket..."
until mariadb-admin ping -u root -p"${MYSQL_ROOT_PASSWORD}" --host=localhost &>/dev/null; do
    sleep 1
done
echo "✅ MariaDB TCP socket ready."

# --- Keep PID 1 foreground ---
wait $MYSQL_PID
