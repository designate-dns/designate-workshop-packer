#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install neutron-server neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms neutron-l3-agent neutron-dhcp-agent

ADMIN_TENANT_ID=`keystone tenant-list | grep ' admin ' | cut -d' ' -f2`

cp /tmp/files/neutron.conf /etc/neutron/neutron.conf
cp /tmp/files/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
cp /tmp/files/l3_agent.ini /etc/neutron/l3_agent.ini
cp /tmp/files/metadata_agent.ini /etc/neutron/metadata_agent.ini
cp /tmp/files/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i "s/%ADMIN_TENANT_ID%/$ADMIN_TENANT_ID/" /etc/neutron/neutron.conf

ip link add type veth

ovs-vsctl add-br br-int
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex veth0

service neutron-server restart
sleep 5
service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

sleep 5

source /home/vagrant/openrc.admin

# Create default external network
neutron net-create ext-net --router:external=True
neutron subnet-create ext-net --name ext-subnet \
  --allocation-pool start=172.31.255.10,end=172.31.255.254 \
  --disable-dhcp --gateway 172.31.255.1 172.31.255.0/24

# Create default networking config for admin tenant
neutron net-create admin-network
neutron subnet-create admin-network --name admin-subnet --gateway 172.31.254.1 172.31.254.0/24
neutron router-create admin-router
neutron router-interface-add admin-router admin-subnet
neutron router-gateway-set admin-router ext-net

ADMIN_NETWORK_ID=`neutron net-list | grep ' admin-network ' | cut -d' ' -f2`
echo "export OS_NETWORK_ID=$ADMIN_NETWORK_ID" >> /home/vagrant/openrc.admin

# Create default networking config for user tenant
source /home/vagrant/openrc.user
neutron net-create user-network
neutron subnet-create user-network --name user-subnet --gateway 172.31.253.1 172.31.253.0/24
neutron router-create user-router
neutron router-interface-add user-router user-subnet
neutron router-gateway-set user-router ext-net

USER_NETWORK_ID=`neutron net-list | grep ' user-network ' | cut -d' ' -f2`
echo "export OS_NETWORK_ID=$USER_NETWORK_ID" >> /home/vagrant/openrc.user
