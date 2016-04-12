#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install neutron-server neutron-plugin-ml2 neutron-plugin-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent conntrack

source /home/vagrant/openrc.admin

ADMIN_TENANT_ID=`keystone tenant-list | grep ' admin ' | cut -d' ' -f2`

cp /tmp/files/neutron.conf /etc/neutron/neutron.conf
cp /tmp/files/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
cp /tmp/files/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
cp /tmp/files/l3_agent.ini /etc/neutron/l3_agent.ini
cp /tmp/files/metadata_agent.ini /etc/neutron/metadata_agent.ini

sed -i "s/%ADMIN_TENANT_ID%/$ADMIN_TENANT_ID/" /etc/neutron/neutron.conf

neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head

ip link add type veth

service neutron-server restart
service neutron-linuxbridge-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

sleep 5

# Create default external network
neutron net-create ext-net --router:external
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

# Create default networking config for tenant 1
source /home/vagrant/openrc.user1
neutron net-create tenant1-network
neutron subnet-create tenant1-network --name tenant1-subnet --gateway 172.31.252.1 172.31.252.0/24
neutron router-create tenant1-router
neutron router-interface-add tenant1-router tenant1-subnet
neutron router-gateway-set tenant1-router ext-net

TENANT1_NETWORK_ID=`neutron net-list | grep ' tenant1-network ' | cut -d' ' -f2`
echo "export OS_NETWORK_ID=$TENANT1_NETWORK_ID" >> /home/vagrant/openrc.user1

# Create default networking config for tenant 2
source /home/vagrant/openrc.user2
neutron net-create tenant2-network
neutron subnet-create tenant2-network --name tenant2-subnet --gateway 172.31.253.1 172.31.253.0/24
neutron router-create tenant2-router
neutron router-interface-add tenant2-router tenant2-subnet
neutron router-gateway-set tenant2-router ext-net

TENANT2_NETWORK_ID=`neutron net-list | grep ' tenant2-network ' | cut -d' ' -f2`
echo "export OS_NETWORK_ID=$TENANT2_NETWORK_ID" >> /home/vagrant/openrc.user2
