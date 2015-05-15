#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get install --yes glance-api glance-registry

cp /tmp/files/glance-api.conf /etc/glance/glance-api.conf
cp /tmp/files/glance-registry.conf /etc/glance/glance-registry.conf

su -s /bin/sh -c "glance-manage db_sync" glance

service glance-registry restart
service glance-api restart

sleep 5

source /home/vagrant/openrc.admin

wget --no-check-certificate -O /tmp/cirros-0.3.4-x86_64-disk.img https://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
glance image-create --name "cirros-0.3.4-x86_64" --disk-format qcow2 --container-format bare --is-public True --progress < /tmp/cirros-0.3.4-x86_64-disk.img

rm /tmp/cirros-0.3.4-x86_64-disk.img
