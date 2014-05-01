#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

# Install PowerDNS
mysql -e 'CREATE DATABASE `powerdns` CHARACTER SET utf8 COLLATE utf8_general_ci;'

echo "pdns-backend-mysql	pdns-backend-mysql/dbconfig-install	boolean	false" | debconf-set-selections
apt-get --yes install pdns-server pdns-backend-mysql

cp /tmp/files/pdns.conf /etc/powerdns/pdns.conf
cp /tmp/files/pdns.local.gmysql /etc/powerdns/pdns.d/pdns.local.gmysql

chmod 755 /etc/powerdns/pdns.d
chmod 644 /etc/powerdns/pdns.conf
chmod 644 /etc/powerdns/pdns.d/*

# Copy over base files for the workshop
cp /tmp/files/JSON.sh /home/vagrant/JSON.sh
cp /tmp/files/createserver.sh /home/vagrant/createserver.sh
cp /tmp/files/deleteserver.sh /home/vagrant/deleteserver.sh
cp /tmp/files/getserver.sh /home/vagrant/getserver.sh
cp /tmp/files/listservers.sh /home/vagrant/listservers.sh
cp /tmp/files/getusertoken.sh /home/vagrant/getusertoken.sh
cp /tmp/files/selectenv.sh /home/vagrant/selectenv.sh
cp /tmp/files/designate.conf /home/vagrant/designate.conf.wkshp
chown vagrant:vagrant /home/vagrant/JSON.sh
chown vagrant:vagrant /home/vagrant/createserver.sh
chown vagrant:vagrant /home/vagrant/deleteserver.sh
chown vagrant:vagrant /home/vagrant/getserver.sh
chown vagrant:vagrant /home/vagrant/listservers.sh
chown vagrant:vagrant /home/vagrant/getusertoken.sh
chown vagrant:vagrant /home/vagrant/selectenv.sh
chown vagrant:vagrant /home/vagrant/openrc.admin
chown vagrant:vagrant /home/vagrant/openrc.user1
chown vagrant:vagrant /home/vagrant/openrc.user2
chown vagrant:vagrant /home/vagrant/openrc.user3
chown vagrant:vagrant /home/vagrant/designate.conf.wkshp
chmod 740 /home/vagrant/JSON.sh
chmod 740 /home/vagrant/createserver.sh
chmod 740 /home/vagrant/deleteserver.sh
chmod 740 /home/vagrant/getserver.sh
chmod 740 /home/vagrant/listservers.sh
chmod 740 /home/vagrant/getusertoken.sh
chmod 740 /home/vagrant/selectenv.sh

# Install Required Packages
apt-get --yes install curl

#Clone the designate repos locally
sudo -u vagrant git clone https://github.com/stackforge/designate.git /home/vagrant/designate
sudo -u vagrant git clone https://github.com/stackforge/python-designateclient.git /home/vagrant/python-designateclient

# Make sure everything in vagrant's home is owned by vagrant
chown -R vagrant /home/vagrant
