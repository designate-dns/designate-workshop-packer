#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install openstack-dashboard-ubuntu-theme

dpkg -P openstack-dashboard-ubuntu-theme

service apache2 restart
