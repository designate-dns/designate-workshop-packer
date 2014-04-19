#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install neutron-server neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms neutron-l3-agent neutron-dhcp-agent

cp /tmp/files/neutron.conf /etc/neutron/neutron.conf
cp /tmp/files/dhcp_agent.conf /etc/neutron/dhcp_agent.conf
cp /tmp/files/l3_agent.conf /etc/neutron/l3_agent.conf
cp /tmp/files/metadata_agent.conf /etc/neutron/metadata_agent.conf
cp /tmp/files/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini

rm /var/lib/neutron/neutron.sqlite

ovs-vsctl add-br br-int
ovs-vsctl add-br br-ex
#ovs-vsctl add-port br-ex eth1

service neutron-server restart
sleep 5
service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

sleep 5

source /home/vagrant/openrc.admin

neutron net-create ext-net --shared --router:external=True
neutron subnet-create ext-net --name ext-subnet \
  --allocation-pool start=172.31.255.10,end=172.31.255.254 \
  --disable-dhcp --gateway 172.31.255.1 172.31.255.0/24
