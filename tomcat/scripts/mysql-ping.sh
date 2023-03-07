#!/bin/bash

ATTEMPTS=0

until mysql -u root -h db -e "use identityiq" -proot &> /dev/null
do
  echo "Waiting for identityiq database creation. This may take a few minutes."
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

echo "Waiting for IdentityIQ startup..."
sleep 10

while ! netstat -an | grep "8080 .*LISTEN" &> /dev/null; do
    echo "Waiting for IdentityIQ startup..."
    sleep 5
done
echo "Done"
echo "IdentityIQ can be accessed at http://localhost:$IIQ_PORT/identityiq"

#Kick off the initial load task
cd /usr/local/tomcat/webapps/identityiq/WEB-INF/bin
tmux new-session -d -s iiq
tmux send-keys -t iiq "./iiq console" C-m
sleep 10
tmux send-keys -t iiq "run 'Initial Load'" C-m
sleep 600
tmux send-keys -t iiq "exit" C-m

#do nothing until stopped
tail -f /dev/null