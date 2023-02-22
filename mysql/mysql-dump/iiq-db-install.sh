chmod +x /docker-entrypoint-initdb.d/iiq-db-installupgrade.sh
#chmod +x /docker-entrypoint-initdb.d/iiq-db-object-imports.sh
cd /usr/local/tomcat/webapps/identityiq/WEB-INF/database
echo "Creating database"
mysql -u "$MYSQL_ROOT" -p"$MYSQL_ROOT_PASSWORD" -e "source create_identityiq_tables-8.3.mysql"
echo "Database created"
