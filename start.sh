#!/bin/bash
# Generate random passwords
MYSQL_DB="kalabox"
MYSQL_USER="root"
MYSQL_PASSWORD="root"

if [ ! -f /data/data/ibdata1 ]; then
    # Set up the SQL TABLES
    mysql_install_db
    /usr/bin/mysqld_safe &
    sleep 10s

    # Set up the users
    mysqladmin -u $MYSQL_USER password $MYSQL_PASSWORD
    # This is so the passwords show up in logs.
    echo mysql root password: $MYSQL_PASSWORD

    # Install a base DB for DRUPAL
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DB; GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;"

    killall mysqld
    sleep 10s
fi

# Start all the services
/usr/local/bin/supervisord -n
