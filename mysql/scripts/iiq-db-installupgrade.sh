cd /usr/local/tomcat/webapps/identityiq/WEB-INF/database
echo "Upgrading database"
mysql -u "root" -p"root" -e "source upgrade_identityiq_tables-8.3p1.mysql"
echo "Upgrade completed"