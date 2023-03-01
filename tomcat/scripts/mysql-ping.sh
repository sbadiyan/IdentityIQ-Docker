#!/bin/bash

ATTEMPTS=0

until mysql -u root -h db -e "use identityiq" -proot &> /dev/null
do
  echo "Waiting for identityiq database creation"
  echo "Attempts: $ATTEMPTS"
  sleep 10
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
startup.sh

echo "Waiting for IdentityIQ startup...Listening on port $IIQ_PORT"
sleep 10

while ! netstat -an | grep "$IIQ_PORT .*LISTEN"; do
    echo "Waiting for IdentityIQ startup...Listening on port $IIQ_PORT"
    sleep 5
done
echo "Done"
echo "IdentityIQ can be accessed at http://localhost:$IIQ_PORT/identityiq"

#do nothing until stopped
tail -f /dev/null