#!/bin/bash

set -e

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

DOMAIN_NAME="${WP_DNS}"

sed "s/DOMAIN_NAME/$WP_DNS/g" /conf/nginx.conf > /etc/nginx/nginx.conf

CERT_PATH="/etc/nginx/certs"
CRT="$CERT_PATH/fullchain.crt"
KEY="$CERT_PATH/privkey.key"

mkdir -p "$CERT_PATH"

#create certs if does not exist
if [ ! -f "$CRT" ] || [ ! -s "$CRT" ] || [ ! -f "$KEY" ] || [ ! -s "$KEY" ]; then
  echo "Creating self-signed certificate..."
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CRT" \
    -subj "/C=FR/ST=France/L=Paris/O=Inception/CN=localhost"
else
  echo "Certificate and key already exist."
fi


echo "Waiting for php-fpm on wordpress:9000..."
until nc -z wordpress 9000; do
  echo "Still waiting for php-fpm..."
  sleep 1
done
echo "php-fpm is up!"

exec nginx -g 'daemon off;'
