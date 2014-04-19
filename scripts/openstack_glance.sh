#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get install --yes glance-api glance-registry

cp /tmp/files/glance-api.conf /etc/glance/glance-api.conf
cp /tmp/files/glance-registry.conf /etc/glance/glance-registry.conf

rm /var/lib/glance/glance.sqlite

su -s /bin/sh -c "glance-manage db_sync" glance

service glance-registry restart
service glance-api restart

sleep 5

source /home/vagrant/openrc.admin

wget -O /tmp/cirros-0.3.2-x86_64-disk.img http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img
glance image-create --name "cirros-0.3.2-x86_64" --disk-format qcow2 --container-format bare --is-public True --progress < /tmp/cirros-0.3.2-x86_64-disk.img
