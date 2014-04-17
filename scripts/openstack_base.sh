#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install --yes --force-yes python-software-properties
add-apt-repository --yes cloud-archive:icehouse
apt-get update

apt-get install --yes git mysql-server rabbitmq-server python-pip python-virtualenv
apt-get install --yes python-novaclient python-glanceclient python-keystoneclient python-neutronclient
