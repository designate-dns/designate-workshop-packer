#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install --yes --force-yes python-software-properties
add-apt-repository --yes cloud-archive:icehouse
apt-get update

apt-get install --yes git mysql-server rabbitmq-server vim python-pip python-virtualenv python-mysqldb python-novaclient python-glanceclient python-keystoneclient python-neutronclient python-heatclient

cat > /home/vagrant/.my.cnf <<eof
[mysql]
user=root
password=
host=127.0.0.1
eof
chown vagrant:vagrant /home/vagrant/.my.cnf

mysql -e 'CREATE DATABASE `keystone` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `glance` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `neutron` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `nova` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `heat` CHARACTER SET utf8 COLLATE utf8_general_ci;'

pushd /tmp
tar xfz files.tar.gz
popd

#cp /tmp/files/interfaces /etc/network/interfaces

cp /tmp/files/openrc.admin /home/vagrant/openrc.admin
cp /tmp/files/openrc.user1 /home/vagrant/openrc.user1
cp /tmp/files/openrc.user2 /home/vagrant/openrc.user2
cp /tmp/files/openrc.user3 /home/vagrant/openrc.user3
