#! /bin/bash

if [ -f wp-config.php ]; then return 0; fi

wp core download --allow-root
wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --skip-email --allow-root
wp core install --url=$DOMAIN_NAME --title="$WEBSITE_TITLE" --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --allow-root
wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD --allow-root

exec "$@"
