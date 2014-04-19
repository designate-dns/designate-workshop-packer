#!/bin/bash -ex

export DEBIAN_FRONTEND=noninteractive

apt-get install --yes glance-api glance-registry

cp /tmp/files/etc/glance/glance-api.conf /etc/glance/glance-api.conf
cp /tmp/files/etc/glance/glance-registry.conf /etc/glance/glance-registry.conf

rm /var/lib/glance/glance.sqlite

su -s /bin/sh -c "glance-manage db_sync" glance

service glance-registry restart
service glance-api restart

# TODO: Download + Install CirrOS image
