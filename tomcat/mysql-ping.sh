#!/bin/bash

ATTEMPTS=0

echo "Waiting for identityiq database creation"
until mysql -u $MYSQL_ROOT -h db -e "use identityiq" -p$MYSQL_ROOT_PASSWORD &> /dev/null
do
  echo "Waiting for identityiq database"
  echo "Attempts: $ATTEMPTS"
  sleep 5
  ATTEMPTS=$((ATTEMPTS+1))
done
echo "Database created"

result=$(mysql -u $MYSQL_ROOT -h db -e "select 1 from $MYSQL_DATABASE.spt_identity" -p$MYSQL_ROOT_PASSWORD)
if [ -z "$result" ]
  then
    cd /usr/local/bin
    ./iiq-db-object-imports.sh
  else
    echo "Database is already initialized"
fi

until mysql -u $MYSQL_ROOT -h db -e "select 1 from $MYSQL_DATABASE.spt_identity" -p$MYSQL_ROOT_PASSWORD &> /dev/null
do
  echo "Waiting for MySQL"
  echo "Attempts: $ATTEMPTS"
  sleep 5
  ATTEMPTS=$((ATTEMPTS+1))
done
echo "MySQL is running"

echo "Starting tomcat"
cd /usr/local/tomcat/bin
catalina.sh run