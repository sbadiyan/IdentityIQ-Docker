FROM tomcat:9.0.71-jdk17

ARG IIQ_VERSION=8.3
ARG IIQ_PATCH=p2

WORKDIR /usr/local/tomcat
RUN cp -r webapps.dist/manager webapps/manager
COPY ./context.xml ./webapps/manager/META-INF
COPY ./tomcat-users.xml ./conf

RUN mkdir -p /usr/local/tomcat/webapps/identityiq
WORKDIR /usr/local/tomcat/webapps/identityiq
#Copy and expand the war file
COPY ./iiq/$IIQ_VERSION/identityiq.war .
RUN jar -xvf identityiq.war
RUN rm identityiq.war

#Copy and expand the patch file
RUN if [ -n "$IIQ_PATCH" ]; then \
        COPY ./iiq/$IIQ_VERSION/identityiq-$IIQ_VERSION$IIQ_PATCH.jar . && \
        jar xf identityiq-$IIQ_VERSION$IIQ_PATCH.jar && \
        rm identityiq-$IIQ_VERSION$IIQ_PATCH.jar; \
    fi

COPY ./iiq/iiq.properties ./WEB-INF/classes

WORKDIR /usr/local/iiq/demo/data
COPY ./iiq/demo/data .
COPY ./iiq/demo/xml /usr/local/iiq/demo/xml

RUN apt update
RUN apt install -y vim
RUN apt install sudo
RUN usermod -aG sudo root
RUN apt install -y mysql-client
RUN apt install -y net-tools
RUN apt install -y tmux

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