#!/bin/bash

IIQ_VERSION=""
PORT=""
USERNAME=""
PASS=""

if (/usr/local/bin/docker --version | grep -q 'Docker version') 
then
    echo "Docker is installed"
else
    echo "Docker must be installed and running. Please visit https://www.docker.com to download the latest version."
    exit 1;
fi

while  [ "$IIQ_VERSION" = "" ] ; do

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

done

if (test "$IIQ_VERSION" = "")
    then
        echo "The version cannot be blank" >&2
        exit 1;
fi

sed -i~ '/^IIQ_VERSION=/s/=.*/='$IIQ_VERSION'/' .env

if test $? -eq 0; then
        echo 'IIQ version set to ' $IIQ_VERSION >&2
else
        echo 'IIQ version selection failed' >&2
        exit 1
fi

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
echo "Done" >&2
echo "IIQ can be accessed at http://localhost:8080/identityiq"
exit 1;