#!/bin/sh

#set -x

USERNAME=$1
PASSWORD=$2
TENANT=$3
TMPFILE=/var/tmp/$$.tmp

# Check if the KEYSTONE_URL has been set in the environment.
if [ -z "$KEYSTONE_URL" ] ; then

    # Set the KEYSTONE_URL to the default.
    KEYSTONE_URL=http://localhost:5000/v2.0
fi

TEMPORARY_TOKEN=`curl -s \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-X POST \
-d '{"auth": {"passwordCredentials": {"username": "'$USERNAME'", "password": "'$PASSWORD'"}}}' \
$KEYSTONE_URL/tokens | ./JSON.sh | grep -F -e "[\"access\",\"token\",\"id\"]" | sed -e 's/^.*   //' -e 's/^"//' -e 's/"$//'`

curl -s \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "X-Auth-Token: $TEMPORARY_TOKEN" \
-X GET \
$KEYSTONE_URL/tenants | ./JSON.sh > $TMPFILE

while read LINE ; do

    VALUE=`echo $LINE | grep -e "[\"tenants\",[0-9][0-9]*,\"id\"]"`
    if [ "$?" = "0" ] ; then
    VALUE_ID=`echo $VALUE | sed -e 's/^.*[ \t]//' -e 's/^"//' -e 's/"$//'`
    fi
    VALUE=`echo $LINE | grep -e "[\"tenants\",[0-9][0-9]*,\"name\"]"`
    if [ "$?" = "0" ] ; then
    VALUE_NAME=`echo $VALUE | sed -e 's/^.*[ \t]//' -e 's/^"//' -e 's/"$//'`
    if [ "$VALUE_NAME" = "$TENANT" ] ; then
        TENANT_ID=$VALUE_ID
        break
    fi
    fi

done < $TMPFILE
rm $TMPFILE

PERMANENT_TOKEN=`curl -s \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-X POST \
-d '{"auth": {"project": "'$TENANT'", "passwordCredentials": {"username": "'$USERNAME'", "password": "'$PASSWORD'"}, "tenantId": "'$TENANT_ID'"}}' \
$KEYSTONE_URL/tokens | ./JSON.sh | grep -F -e "[\"access\",\"token\",\"id\"]" | sed -e 's/^.*   //' -e 's/^"//' -e 's/"$//'`

echo $PERMANENT_TOKEN

exit 0
