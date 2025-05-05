#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB..."
	mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql --bind-address=0.0.0.0
fi

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

echo "Starting temporary MariaDB..."
mysqld --skip-networking=0 --socket=/run/mysqld/mysqld.sock --bind-address=0.0.0.0 &
pid=$! 

echo "Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock --user=root -p"${DB_ROOT_PASSWORD}" ping --silent; do
    sleep 1
done


echo "Securing MariaDB installation..."
mysql --user=root --socket=/run/mysqld/mysqld.sock -p"${DB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
DROP USER IF EXISTS '${ADMIN_USER}'@'localhost';
DROP USER IF EXISTS '${ADMIN_USER}'@'%';
CREATE USER '${ADMIN_USER}'@'localhost' IDENTIFIED BY '${ADMIN_USER_PSWD}';
CREATE USER '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_USER_PSWD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${ADMIN_USER}'@'localhost';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${ADMIN_USER}'@'%';
DROP DATABASE IF EXISTS test;
DROP DATABASE IF EXISTS performance_schema;
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

echo "Shutting down temporary MariaDB..."
mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown


echo "Starting MariaDB..."
exec mysqld --bind-address=0.0.0.0 "$@"
