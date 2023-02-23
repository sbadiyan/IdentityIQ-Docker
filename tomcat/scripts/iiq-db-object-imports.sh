cd /usr/local/tomcat/webapps/identityiq/WEB-INF/bin
sudo chmod 777 iiq
echo "Initializing the database"
./iiq console -c "import init.xml"
./iiq console -c "import init-lcm.xml"
echo "Database initialized"
echo "Applying patch"
./iiq patch 8.3p1