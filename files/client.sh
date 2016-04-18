#/bin/bash
set -e
set -o pipefail

source openrc.user1
echo "source user1 credentials"

openstack zone list
echo "listed zones - nothing here!"

echo "creating openstack.org."
openstack zone create --email user@openstack.org openstack.org.

sleep 20
openstack zone list

echo "creating a recordset"
openstack recordset create --type A --records 127.0.0.1 --ttl 300 openstack.org. foo

sleep 20
openstack recordset list openstack.org.

echo "deleting openstack.org"
openstack zone delete openstack.org.

sleep 5
openstack zone list
echo "listed zones - nothing here"

echo "importing a zone"
openstack zone import create importdemo.txt

sleep 10
openstack zone import list

IMPORT_ID=$(openstack zone import list -f value | cut -d ' ' -f 1)
openstack zone import delete "$IMPORT_ID"

openstack zone list

echo "export the zone!"
openstack zone export create designatedemo.com.

sleep 10
EXPORT_ID=$(openstack zone export list -f value | cut -d ' ' -f 1)
openstack zone export showfile "$EXPORT_ID" -f value

openstack zone export delete "$EXPORT_ID"

openstack zone delete designatedemo.com.

