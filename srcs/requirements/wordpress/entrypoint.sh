#!/bin/bash

set -e

if [ ! -f "${WP_PATH}/wp-load.php" ]; then
  wp core download --path="${WP_PATH}" --allow-root
fi

cd "${WP_PATH}" || exit 1


if [ ! -f "${WP_PATH}/wp-config.php" ]; then
	wp config create \
	  --dbname="${DB_NAME}" \
	  --dbuser="${ADMIN_USER}" \
	  --dbpass="${ADMIN_USER_PSWD}" \
	  --dbhost="mariadb" \
	  --path="${WP_PATH}" \
	  --allow-root
fi


 wp core install \
	--url="${WP_DNS}" \
	--title="WORDPRESS INCEPTION" \
	--admin_user="${ADMIN_USER}" \
	--admin_password="${ADMIN_USER_PSWD}" \
	--admin_email="dev@fake.local" \
	--path="${WP_PATH}" \
	 --allow-root

current_url=$(wp option get siteurl --allow-root --path="$WP_PATH")

if [ "$current_url" != "$WP_DNS" ] && [ -n "$current_url" ]; then
  echo "[INFO] Updating WordPress siteurl and home to $WP_DNS..."
  wp option update siteurl "https://${WP_DNS}" --allow-root --path="$WP_PATH"
  wp option update home "https://${WP_DNS}" --allow-root --path="$WP_PATH"
fi


mkdir -p /run/php

sed -i 's|^listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf


exec php-fpm -F

