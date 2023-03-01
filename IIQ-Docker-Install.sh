#!/bin/bash

IIQ_VERSION=""
IIQ_PORT=""
MYSQL_PORT=""
USERNAME=""
PASS=""
ENVFILE=".env"

if (/usr/local/bin/docker --version | grep -q 'Docker version') 
then
    echo "Docker is installed"
else
    echo "Docker must be installed and running. Please visit https://www.docker.com to download the latest version."
    exit 1;
fi


IIQ_VERSION=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Please specify the version and patch number of IIQ (i.e. 8.3p1) you wish to install:" with title "Select IIQ version" default answer "8.3p1"
        set IIQ_VERSION to the (text returned of the result)
    on error number -128
        set IIQ_VERSION to ""
    end try
    return IIQ_VERSION
end tell')


if (test "$IIQ_VERSION" = "")
    then
        echo "The version cannot be blank" >&2
        exit 1;
fi

echo "IIQ_VERSION=$IIQ_VERSION" >> $ENVFILE

if test $? -eq 0; then
        echo 'IIQ version set to' $IIQ_VERSION >&2
else
        echo 'IIQ version selection failed' >&2
        exit 1
fi

IIQ_PORT=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Please specify the port for IIQ:" with title "Select IIQ port" default answer "8080"
        set IIQ_PORT to the (text returned of the result)
    on error number -128
        set IIQ_PORT to ""
    end try
    return IIQ_PORT
end tell')

echo "Port set to" $IIQ_PORT

if (test "$IIQ_PORT" = "")
    then
        echo "The port cannot be blank" >&2
        exit 1;
fi

echo "IIQ_PORT=$IIQ_PORT" >> $ENVFILE

MYSQL_PORT=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Please specify the port for MySQL:" with title "Select MySQL port" default answer "3306"
        set MYSQL_PORT to the (text returned of the result)
    on error number -128
        set MYSQL_PORT to ""
    end try
    return MYSQL_PORT
end tell')

echo "MySQL port set to" $MYSQL_PORT

if (test "$MYSQL_PORT" = "")
    then
        echo "The MySQL port cannot be blank" >&2
        exit 1;
fi

echo "MYSQL_PORT=$MYSQL_PORT" >> $ENVFILE


USERNAME=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Please enter your username:" with title "Enter username" default answer "edgile"
        set USERNAME to the (text returned of the result)
    on error number -128
        set USERNAME to ""
    end try
    return USERNAME
end tell')


if (test "$USERNAME" = "")
    then
        echo "The username cannot be blank" >&2
        exit 1;
fi

PASS=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Please enter your password:" with title "Enter password" default answer ""
        set PASS to the (text returned of the result)
    on error number -128
        set PASS to ""
    end try
    return PASS
end tell')

echo "Running docker compose"
/usr/local/bin/docker login -u $USERNAME -p $PASS identityiqdocker.azurecr.io
/usr/local/bin/docker compose up

exit 1;