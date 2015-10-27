#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

# Install PowerDNS
mysql -e 'CREATE DATABASE `powerdns` CHARACTER SET utf8 COLLATE utf8_general_ci;'

echo "pdns-backend-mysql	pdns-backend-mysql/dbconfig-install	boolean	false" | debconf-set-selections
apt-get --yes install pdns-server pdns-backend-mysql zookeeper

cp /tmp/files/pdns.conf /etc/powerdns/pdns.conf

rm /etc/powerdns/bindbackend.conf /etc/powerdns/pdns.d/*
chmod 755 /etc/powerdns/pdns.d
chmod 644 /etc/powerdns/pdns.conf

# Install Required Packages
apt-get --yes install curl
apt-get build-dep --yes python-lxml

# Clone the designate repos locally
sudo -u vagrant git clone https://github.com/openstack/designate.git /home/vagrant/designate
sudo -u vagrant git clone https://github.com/openstack/python-designateclient.git /home/vagrant/python-designateclient
sudo -u vagrant git clone https://github.com/openstack/designate-dashboard.git /home/vagrant/designate-dashboard

pushd /home/vagrant/designate
git checkout stable/liberty
popd

pushd /home/vagrant/designate-dashboard
git checkout stable/liberty
popd

wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
sudo python /tmp/get-pip.py

# Pre-Install Designate's Dependancies
pip install -r /home/vagrant/designate/requirements.txt
pip install -r /home/vagrant/python-designateclient/requirements.txt
pip install -r /home/vagrant/designate-dashboard/requirements.txt

# Pre-Install Designate Upstart scripts
pushd /tmp/files
ls *.upstart | while read f; do sudo cp $f $(echo /etc/init/$f | sed "s/.upstart$//g"); done
popd

# Copy over base files for the workshop
cp /tmp/files/designate.conf /home/vagrant/designate.conf.workshop
cp /tmp/files/designate.conf /home/vagrant/designate/etc/designate/designate.conf
cp /tmp/files/install-designate.sh /home/vagrant/install-designate.sh
cp /tmp/files/example.py /home/vagrant/example.py
cp /tmp/files/short_url.py /home/vagrant/short_url.py

# Make sure everything in vagrant's home is owned by vagrant
chown -R vagrant:vagrant /home/vagrant/*
chown -R vagrant:vagrant /home/vagrant/.cache
chmod 775 /home/vagrant/*.sh
chmod 775 /home/vagrant/example.py
chmod +x /home/vagrant/example.py
