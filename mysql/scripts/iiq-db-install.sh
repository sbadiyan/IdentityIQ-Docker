cd /usr/local/tomcat/webapps/identityiq/WEB-INF/database
echo "Creating database"
mysql -u "root" -p"root" -e "source create_identityiq_tables-$IIQ_BASE.mysql"
echo "Database created"
