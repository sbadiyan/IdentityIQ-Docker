FROM tomcat:9.0.71-jdk17

WORKDIR /usr/local/tomcat
RUN cp -r webapps.dist/manager webapps/manager
COPY ./context.xml ./webapps/manager/META-INF
COPY ./tomcat-users.xml ./conf

RUN mkdir -p /usr/local/tomcat/webapps/identityiq
WORKDIR /usr/local/tomcat/webapps/identityiq
COPY ./iiq/identityiq.war .
COPY ./iiq/identityiq-8.3p1.jar .
RUN jar -xvf identityiq.war
RUN jar xf identityiq-8.3p1.jar
RUN rm identityiq.war
RUN rm identityiq-8.3p1.jar

COPY ./iiq/iiq.properties ./WEB-INF/classes

RUN apt update
RUN apt install -y vim
RUN apt install sudo
RUN usermod -aG sudo root
RUN apt install -y mysql-client
RUN apt install net-tools

EXPOSE 8080

#Add mysql waiting script
COPY ./scripts/mysql-ping.sh /home/mysql-ping.sh
RUN chmod +x /home/mysql-ping.sh

#Add IIQ initialization script
COPY ./scripts/iiq-db-object-imports.sh /usr/local/bin/iiq-db-object-imports.sh
RUN chmod +x /usr/local/bin/iiq-db-object-imports.sh

#Deployment commmands
#docker login
#docker compose build --pull
#docker compose push