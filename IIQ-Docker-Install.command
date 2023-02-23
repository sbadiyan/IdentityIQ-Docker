
read -p "Please specify the version and patch number of IIQ (i.e. 8.3p1) you wish to install:  " IIQ_VERSION
echo ""

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

echo "Running docker compose"
docker compose up -d
echo "Done" >&2