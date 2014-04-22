#!/bin/bash

set -ex

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
