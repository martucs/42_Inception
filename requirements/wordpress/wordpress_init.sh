#! /bin/bash

if [ -f wp-config.php ]; then return 0; fi

until wp core download --allow-root; do
	echo "Waiting for network..."
	sleep 3
done

echo "waiting for MariaDB to accept connections"
while ! exec 3<>/dev/tcp/$DATABASE_HOST/3306; do
	sleep 3
done
echo "MariaDB is ready!"
wp config create --dbname=$DATABASE_NAME \
		 --dbuser=$DATABASE_USER_NAME \
		 --dbpass=$DATABASE_USER_PASSWORD \
		 --dbhost=$DATABASE_HOST \
		 --allow-root
wp core install --url=$DOMAIN_NAME \
		--title="$WORDPRESS_TITLE" \
		--admin_user=$WORDPRESS_ADMIN_USER \
		--admin_password=$WORDPRESS_ADMIN_PASSWORD \
		--admin_email=$WORDPRESS_ADMIN_EMAIL \
		--allow-root
wp user create $WORDPRESS_AUTHOR_USER $WORDPRESS_AUTHOR_EMAIL --role=author --user_pass=$WORDPRESS_AUTHOR_PASSWORD --allow-root

exec "$@"
