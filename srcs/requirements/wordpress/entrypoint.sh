#!/bin/bash

set -e

if [ ! -f "${WP_PATH}/wp-load.php" ]; then
  wp core download --path="${WP_PATH}" --allow-root
fi

cd "${WP_PATH}" || exit 1


if [ ! -f "${WP_PATH}/wp-config.php" ]; then
	wp config create \
	  --dbname="${DB_NAME}" \
	  --dbuser="${DB_USER}" \
	  --dbpass="${DB_PASSWORD}" \
	  --dbhost="mariadb" \
	  --path="${WP_PATH}" \
	  --allow-root
	

	wp core install \
		--url="${WP_DNS}" \
		--title="WORDPRESS INCEPTION" \
		--admin_user="${ADMIN_USER}" \
		--admin_password="${ADMIN_USER_PSWD}" \
		--admin_email="dev@fake.local" \
		--path="${WP_PATH}" \
		--allow-root
		
	wp user create \
		--path="/var/www/html" \
		--allow-root $WP_USER $WP_EMAIL \
		--user_pass=$WP_PASS \
		--role='contributor'
fi




mkdir -p /run/php

FOUND=""
for c in /usr/local/etc/php-fpm.d/www.conf /etc/php/*/fpm/pool.d/www.conf; do
  for f in $c; do
    if [ -f "$f" ]; then
		sed -ri 's@^;?\s*listen\s*=.*$@listen = [::]:9000@' "$f"
      FOUND="$f"; break
    fi
  done
  [ -n "$FOUND" ] && break
done
[ -z "$FOUND" ] && echo "WARNING: www.conf can not be found, no modification applied."

echo "Wordpress ready to go"

exec php-fpm -F

