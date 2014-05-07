#!/bin/bash

set -ex

# Install Designate and its dependencies
cd /home/vagrant/designate
sudo apt-get -y build-dep python-lxml
sudo pip install -r requirements.txt -r test-requirements.txt
sudo python setup.py develop

# Make copies of designate config files from templates
cd /home/vagrant/designate/etc/designate
ls *.sample | while read f; do cp $f $(echo $f | sed "s/.sample$//g"); done

# Copy over config file with pre-set values to designate.conf
# (Replace contents of designate.conf with contents of file /home/vagrant/designate.conf.wkshp)
cp /home/vagrant/designate.conf.wkshp ./designate.conf

# Create directory for maintaining designate state information (this directory was referenced by 'state_path' variable in designate.conf file)
sudo mkdir /var/lib/designate

# Create directory for maintaining designate log files (this directory was referenced by 'logdir' variable in designate.conf file)
sudo mkdir /home/vagrant/designate/log

# Create, Initialize and sync the databases
# The Designate database
mysql -e 'CREATE DATABASE `designate` CHARACTER SET utf8 COLLATE utf8_general_ci;'
sudo designate-manage database init
sudo designate-manage database sync

# The PowerDNS database
# (Database already exists. Just init and sync)
sudo designate-manage powerdns init
sudo designate-manage powerdns sync

# Start the Designate Central Service
sudo designate-central &

# Start the Designate API Service
sudo designate-api &

# Setup the Designate Keystone service and endpoints
# First set user 'admin' particulars then create service and endpoint
source /home/vagrant/openrc.admin
keystone service-create --name designate --type dns --description "Designate Service"
keystone endpoint-create --service designate --publicurl http://127.0.0.1:9001/v1 --adminurl http://127.0.0.1:9001/v1 --internalurl http://127.0.0.1:9001/v1

# Install Designate Client
cd /home/vagrant/python-designateclient
sudo pip install -r requirements.txt -r test-requirements.txt
sudo python setup.py develop


