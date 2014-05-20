#!/bin/bash
# Generate random passwords
MYSQL_DB="kalabox"
MYSQL_USER="root"
MYSQL_PASSWORD="root"

# Start mysql
/usr/bin/mysqld_safe &
sleep 10s

DBEXISTS=$(mysql --batch --skip-column-names -e "SHOW DATABASES LIKE '"$MYSQL_DB"';" | grep "$MYSQL_DB" > /dev/null; echo "$?")
if [ ! $DBEXISTS -eq 0 ];then
  # This is so the passwords show up in logs.
  echo mysql root password: $MYSQL_PASSWORD
  mysqladmin -u $MYSQL_USER password $MYSQL_PASSWORD
  mysql -u$MYSQL_PASSWORD -p$MYSQL_PASSWORD -e "CREATE DATABASE $MYSQL_DB; GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;"
  killall mysqld
  sleep 10s
fi

# start all the services
/usr/local/bin/supervisord -n
