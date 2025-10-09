#! /bin/bash

if [ -f wp-config.php ]; then return 0; fi

wp core download --allow-root
wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --allow-root
wp core install --url=$DOMAIN_NAME --title="$WORDPRESS_TITLE" --admin_user=$WORDPRESS_ADMIN_USER --admin_password=$WORDPRESS_ADMIN_PASSWORD --allow-root
wp user create $WORDPRESS_AUTHOR_USER $WORDPRESS_AUTHOR_EMAIL --role=author --user_pass=$WORDPRESS_AUTHOR_PASSWORD --allow-root

exec "$@"
