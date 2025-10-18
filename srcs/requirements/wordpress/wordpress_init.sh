#!/bin/bash
set -e

# --- Wait for MariaDB first ---
echo "⏳ Waiting for MariaDB to accept connections..."
while ! (echo > /dev/tcp/$DATABASE_HOST/3306) 2>/dev/null; do
    sleep 3
done

until mariadb -h $DATABASE_HOST -u $DATABASE_USER -p"$DATABASE_PASSWORD" -e "SELECT 1" &>/dev/null; do
  echo "Waiting for MariaDB credentials..."
  sleep 2
done

echo "✅ MariaDB is ready!"

# --- Download WordPress core if missing ---
if [ ! -f index.php ]; then
    echo "📦 Downloading WordPress..."
    until wp core download --allow-root; do
        echo "Waiting for network..."
        sleep 3
    done
fi

# --- Create wp-config.php if missing ---
if [ ! -f wp-config.php ]; then
    echo "⚙️ Creating wp-config.php..."
    wp config create --dbname=$DATABASE_NAME \
                     --dbuser=$DATABASE_USER_NAME \
                     --dbpass=$DATABASE_USER_PASSWORD \
                     --dbhost=$DATABASE_HOST \
                     --allow-root
fi

# --- Database integrity check ---
# Even if wp-config.php exists, make sure DB has WordPress tables
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    echo "🧱 Database missing or empty — installing WordPress..."
    wp core install --url=$DOMAIN_NAME \
                    --title="$WORDPRESS_TITLE" \
                    --admin_user=$WORDPRESS_ADMIN_USER \
                    --admin_password=$WORDPRESS_ADMIN_PASSWORD \
                    --admin_email=$WORDPRESS_ADMIN_EMAIL \
                    --allow-root
else
    echo "✅ WordPress already configured and DB is valid."
fi

# --- Ensure author user exists ---
if ! wp user get $WORDPRESS_AUTHOR_USER --field=ID --allow-root >/dev/null 2>&1; then
    echo "👤 Creating author user..."
    wp user create $WORDPRESS_AUTHOR_USER $WORDPRESS_AUTHOR_EMAIL \
        --role=author \
        --user_pass=$WORDPRESS_AUTHOR_PASSWORD \
        --allow-root
else
    echo "✅ Author user already exists. Skipping creation."
fi

# --- Start PHP-FPM ---
exec "$@"
