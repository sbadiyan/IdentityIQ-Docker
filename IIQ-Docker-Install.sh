#!/bin/bash

IIQ_VERSION=""
IIQ_BASE=""
IIQ_PATCH=""
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

#Open Docker, only if is not running
if (! /usr/local/bin/docker stats --no-stream &> /dev/null); then
  # On Mac OS this would be the terminal command to launch Docker
  open --background -a Docker
 #Wait until Docker daemon is running and has completed initialisation
while (! /usr/local/bin/docker stats --no-stream &> /dev/null); do 
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  sleep 6
done
fi


IIQ_VERSION=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Please specify the version and patch number of IIQ (e.g. 8.3p1) you wish to use:" with title "Select IIQ version" default answer "8.3p2"
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

if [[ $IIQ_VERSION == *"p"* ]]; then
    IIQ_BASE=$(echo $IIQ_VERSION | cut -d 'p' -f 1)
    IIQ_PATCH="p$(echo $IIQ_VERSION | cut -d 'p' -f 2)"
else
    IIQ_BASE=$IIQ_VERSION
fi
echo "IIQ_BASE=$IIQ_BASE" >> $ENVFILE
echo "IIQ_PATCH=$IIQ_PATCH" >> $ENVFILE

if test $? -eq 0; then
        echo 'IIQ version set to' $IIQ_VERSION >&2
else
        echo 'IIQ version selection failed' >&2
        exit 1
fi

USE_DEMO_DATA=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Would you like to include demo data with your install (Yes or No)?" with title "Include Demo Data" default answer "Yes"
        set USE_DEMO_DATA to the (text returned of the result)
    on error number -128
        set USE_DEMO_DATA to "Yes"
    end try
    return USE_DEMO_DATA
end tell')

if (test "$USE_DEMO_DATA" = "")
    then
        USE_DEMO_DATA="No"
fi

echo "USE_DEMO_DATA=$USE_DEMO_DATA" >> $ENVFILE

IIQ_PORT=$(osascript -e '
tell application "Finder"
    activate
    try
        display dialog "Please specify the port for IIQ:" with title "Select IIQ port" default answer "7070"
        set IIQ_PORT to the (text returned of the result)
    on error number -128
        set IIQ_PORT to ""
    end try
    return IIQ_PORT
end tell')

while netstat -an | grep "$IIQ_PORT .*LISTEN" &> /dev/null; do
    if (test "$IIQ_PORT" = "")
        then
            echo "The IIQ port cannot be blank"
            exit 1;
    fi
    echo "The port you selected for IIQ is already in use on your machine. Please enter a different port."
    IIQ_PORT=$(osascript -e '
    tell application "Finder"
        activate
        try
            display dialog "Please specify the port for IIQ:" with title "Enter IIQ port" default answer "7070"
            set IIQ_PORT to the (text returned of the result)
        on error number -128
            set IIQ_PORT to ""
        end try
        return IIQ_PORT
    end tell')
done

echo "IIQ port set to" $IIQ_PORT


echo "IIQ_PORT=$IIQ_PORT" >> $ENVFILE

MYSQL_PORT=$(osascript -e '
    tell application "Finder"
        activate
        try
            display dialog "Please specify the port for MySQL:" with title "Enter MySQL port" default answer "3307"
            set MYSQL_PORT to the (text returned of the result)
        on error number -128
            set MYSQL_PORT to ""
        end try
        return MYSQL_PORT
    end tell')

while netstat -an | grep "$MYSQL_PORT .*LISTEN" &> /dev/null; do
    if (test "$MYSQL_PORT" = "")
        then
            echo "The MySQL port cannot be blank"
            exit 1;
    fi
    echo "The port you selected for MySQL is already in use on your machine. Please enter a different port."
    MYSQL_PORT=$(osascript -e '
    tell application "Finder"
        activate
        try
            display dialog "Please specify the port for MySQL:" with title "Select MySQL port" default answer "3307"
            set MYSQL_PORT to the (text returned of the result)
        on error number -128
            set MYSQL_PORT to ""
        end try
        return MYSQL_PORT
    end tell')
done

echo "MySQL port set to" $MYSQL_PORT

echo "MYSQL_PORT=$MYSQL_PORT" >> $ENVFILE

mkdir IIQ-$IIQ_VERSION
cp .env ./IIQ-$IIQ_VERSION
cp docker-compose.yml ./IIQ-$IIQ_VERSION
cd IIQ-$IIQ_VERSION

if (! /usr/local/bin/docker compose up) 
    then
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
        
        while (! /usr/local/bin/docker login -u $USERNAME -p $PASS identityiqdocker.azurecr.io &> /dev/null); do
            echo "Incorrect username/password. Please try again."
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
        done
        echo "Login successful"
        echo "Running docker compose"
        /usr/local/bin/docker compose up
fi

exit 1;