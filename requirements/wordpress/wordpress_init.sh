#!/bin/bash
set -e

# Only initialize if wp-config.php is missing
if [ -f wp-config.php ]; then
    echo "✅ WordPress already configured. Skipping setup."
    exec "$@"
fi

# Download WordPress core only if not already present
if [ ! -f index.php ]; then
    echo "📦 Downloading WordPress..."
    until wp core download --allow-root; do
        echo "Waiting for network..."
        sleep 3
    done
fi

echo "⏳ Waiting for MariaDB to accept connections..."
while ! (echo > /dev/tcp/$DATABASE_HOST/3306) 2>/dev/null; do
    sleep 3
done
echo "✅ MariaDB is ready!"

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
    wp config create --dbname=$DATABASE_NAME \
                     --dbuser=$DATABASE_USER_NAME \
                     --dbpass=$DATABASE_USER_PASSWORD \
                     --dbhost=$DATABASE_HOST \
                     --allow-root
fi

# Install WordPress if not already installed
if ! wp core is-installed --allow-root; then
    wp core install --url=$DOMAIN_NAME \
                    --title="$WORDPRESS_TITLE" \
                    --admin_user=$WORDPRESS_ADMIN_USER \
                    --admin_password=$WORDPRESS_ADMIN_PASSWORD \
                    --admin_email=$WORDPRESS_ADMIN_EMAIL \
                    --allow-root
else
    echo "✅ WordPress already installed. Skipping core install."
fi

# Create author user if not existing
if ! wp user get $WORDPRESS_AUTHOR_USER --field=ID --allow-root >/dev/null 2>&1; then
    wp user create $WORDPRESS_AUTHOR_USER $WORDPRESS_AUTHOR_EMAIL \
        --role=author \
        --user_pass=$WORDPRESS_AUTHOR_PASSWORD \
        --allow-root
else
    echo "✅ Author user already exists. Skipping creation."
fi

exec "$@"
