FROM tomcat:9.0.71-jdk17

WORKDIR /usr/local/tomcat
RUN cp -r webapps.dist/manager webapps/manager
COPY ./context.xml ./webapps/manager/META-INF
COPY ./tomcat-users.xml ./conf

RUN mkdir -p /usr/local/tomcat/webapps/identityiq
WORKDIR /usr/local/tomcat/webapps/identityiq
COPY ./identityiq.war .
COPY ./identityiq-8.3p1.jar .
RUN jar -xvf identityiq.war
RUN jar xf identityiq-8.3p1.jar

COPY ./iiq.properties ./WEB-INF/classes

RUN apt update
RUN apt install -y vim
RUN apt install sudo
RUN usermod -aG sudo root
RUN apt install -y mysql-client

EXPOSE 8080

#Add mysql waiting script
COPY ./mysql-ping.sh /home/mysql-ping.sh
RUN chmod +x /home/mysql-ping.sh

#Add IIQ initialization script
COPY ./iiq-db-object-imports.sh /usr/local/bin/iiq-db-object-imports.sh
RUN chmod +x /usr/local/bin/iiq-db-object-imports.sh
