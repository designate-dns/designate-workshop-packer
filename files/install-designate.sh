#!/bin/bash

set -ex

# Install Designate and its dependencies
cd /home/vagrant/designate
sudo pip install -r requirements.txt
sudo python setup.py develop

# Make copies of designate config files from templates
cd /home/vagrant/designate/etc/designate
ls *.sample | while read f; do cp $f $(echo $f | sed "s/.sample$//g"); done

# Copy over config file with pre-set values to designate.conf
# (Replace contents of designate.conf with contents of file /home/vagrant/designate.conf.wkshp)
cp /home/vagrant/designate.conf.workshop ./designate.conf

# Create directory for maintaining designate state information (this directory was referenced by 'state_path' variable in designate.conf file)
mkdir /home/vagrant/state/ || :

# Create directory for maintaining designate log files (this directory was referenced by 'logdir' variable in designate.conf file)
mkdir /home/vagrant/logs/ || :

# Create, Initialize and sync the databases
# The Designate database
mysql -e 'DROP DATABASE IF EXISTS `designate`;'
mysql -e 'CREATE DATABASE `designate` CHARACTER SET utf8 COLLATE utf8_general_ci;'
designate-manage database sync

# The PowerDNS database
mysql -e 'DROP DATABASE IF EXISTS `powerdns`;'
mysql -e 'CREATE DATABASE `powerdns` CHARACTER SET utf8 COLLATE utf8_general_ci;'
designate-manage powerdns sync f26e0b32-736f-4f0a-831b-039a415c481e

# Restart pDNS after replacing it's DB
sudo service pdns restart

# Start the Designate Central Service
sudo stop designate-central || :
sudo start designate-central

# Start the Designate API Service
sudo stop designate-api || :
sudo start designate-api

# Start the Designate mDNS Service
sudo stop designate-mdns || :
sudo start designate-mdns

# Start the Designate Pool Manager Service
sudo stop designate-pool-manager || :
sudo start designate-pool-manager

# Setup the Designate Keystone service and endpoints
# First set user 'admin' particulars then create service and endpoint
source /home/vagrant/openrc.admin

keystone service-list | grep designate | awk '{print $2}' | xargs --no-run-if-empty -n 1 keystone service-delete

keystone service-create --name designate --type dns --description "Designate Service"
keystone endpoint-create --service designate --publicurl http://127.0.0.1:9001/v1 --adminurl http://127.0.0.1:9001/v1 --internalurl http://127.0.0.1:9001/v1

# Install Designate Client
cd /home/vagrant/python-designateclient
sudo pip install -r requirements.txt
sudo python setup.py develop

# Install Designate Horizon Panels
cd /home/vagrant/designate/contrib/designate-dashboard
rm -rf dist/*
python setup.py sdist
sudo pip install dist/*.tar.gz
sudo cp designatedashboard/enabled/_70_dns_add_group.py /usr/share/openstack-dashboard/openstack_dashboard/local/enabled
sudo cp designatedashboard/enabled/_71_dns_project.py /usr/share/openstack-dashboard/openstack_dashboard/local/enabled
sudo service apache2 restart
