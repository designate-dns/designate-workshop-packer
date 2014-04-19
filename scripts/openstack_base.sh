#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install --yes --force-yes python-software-properties
add-apt-repository --yes cloud-archive:icehouse
apt-get update

apt-get install --yes git mysql-server rabbitmq-server python-pip python-virtualenv python-mysqldb python-novaclient python-glanceclient python-keystoneclient python-neutronclient

mysql -e 'CREATE DATABASE `keystone` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `glance` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `neutron` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `nova` CHARACTER SET utf8 COLLATE utf8_general_ci;'

pushd /tmp
tar xfz files.tar.gz
popd

cp /tmp/files/openrc.admin /root/openrc.admin
cp /tmp/files/openrc.user /root/openrc.user
cp /tmp/files/openrc.admin /home/vagrant/openrc.admin
cp /tmp/files/openrc.user /home/vagrant/openrc.user
