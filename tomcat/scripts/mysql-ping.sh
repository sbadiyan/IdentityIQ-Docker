#!/bin/bash

ATTEMPTS=0

until mysql -u root -h db -e "use identityiq" -proot &> /dev/null
do
  echo "Waiting for identityiq database creation"
  echo "Attempts: $ATTEMPTS"
  sleep 5
  ATTEMPTS=$((ATTEMPTS+1))
done

result=$(mysql -u root -h db -e "select 1 from identityiq.spt_identity" -proot)
if [ -z "$result" ]
  then
    cd /usr/local/bin
    ./iiq-db-object-imports.sh
  else
    echo "Database is already initialized"
fi

until mysql -u root -h db -e "select 1 from identityiq.spt_identity" -proot &> /dev/null
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