cd /usr/local/tomcat/webapps/identityiq/WEB-INF/database
echo "Upgrading database"
mysql -u "$MYSQL_ROOT" -p"$MYSQL_ROOT_PASSWORD" -e "source upgrade_identityiq_tables-8.3p1.mysql"
echo "Upgrade completed"