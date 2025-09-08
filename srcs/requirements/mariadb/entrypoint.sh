#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /run/mysqld 2>/dev/null || true

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

echo "Starting temporary MariaDB..."
gosu mysql mysqld --skip-networking=1 --socket=/run/mysqld/mysqld.sock --bind-address=0.0.0.0 &
pid=$!

echo "Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock --user=root -p"${DB_ROOT_PASSWORD}" ping --silent; do
    sleep 1
done

echo "Securing MariaDB installation..."
mysql --user=root --socket=/run/mysqld/mysqld.sock -p"${DB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
DROP USER IF EXISTS '${DB_USER}'@'localhost';
DROP USER IF EXISTS '${DB_USER}'@'%';
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

echo "Shutting down temporary MariaDB..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown

echo "Starting MariaDB..."
exec gosu mysql mysqld --skip-networking=0 --bind-address=0.0.0.0 "$@"
