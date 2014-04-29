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

# Install Required Packages
apt-get --yes install curl

#Clone the designate repos locally
sudo -u vagrant git clone https://github.com/stackforge/designate.git /home/vagrant/designate
sudo -u vagrant git clone https://github.com/stackforge/python-designateclient.git /home/vagrant/python-designateclient

# Make sure everything in vagrant's home is owned by vagrant
chown -R vagrant /home/vagrant
