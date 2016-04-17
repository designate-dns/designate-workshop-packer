#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install --yes --force-yes software-properties-common
/usr/bin/add-apt-repository --yes cloud-archive:mitaka
apt-get update

apt-get install --yes git jq mysql-server rabbitmq-server vim python-pip python-virtualenv python-mysqldb python-novaclient python-glanceclient python-keystoneclient python-neutronclient python-openstackclient

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
mysql -e 'CREATE DATABASE `nova_api` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e 'CREATE DATABASE `nova` CHARACTER SET utf8 COLLATE utf8_general_ci;'

pushd /tmp
tar xfz files.tar.gz
popd
