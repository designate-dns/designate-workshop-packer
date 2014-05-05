#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install neutron-server neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms neutron-l3-agent neutron-dhcp-agent

source /home/vagrant/openrc.admin

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

# Create default networking config for tenant A
source /home/vagrant/openrc.user1
neutron net-create tenantA-network
neutron subnet-create tenantA-network --name tenantA-subnet --gateway 172.31.252.1 172.31.252.0/24
neutron router-create tenantA-router
neutron router-interface-add tenantA-router tenantA-subnet
neutron router-gateway-set tenantA-router ext-net

TENANTA_NETWORK_ID=`neutron net-list | grep ' tenantA-network ' | cut -d' ' -f2`
echo "export OS_NETWORK_ID=$TENANTA_NETWORK_ID" >> /home/vagrant/openrc.user1
echo "export OS_NETWORK_ID=$TENANTA_NETWORK_ID" >> /home/vagrant/openrc.user2

# Create default networking config for tenant B
source /home/vagrant/openrc.user3
neutron net-create tenantB-network
neutron subnet-create tenantB-network --name tenantB-subnet --gateway 172.31.253.1 172.31.253.0/24
neutron router-create tenantB-router
neutron router-interface-add tenantB-router tenantB-subnet
neutron router-gateway-set tenantB-router ext-net

TENANTB_NETWORK_ID=`neutron net-list | grep ' tenantB-network ' | cut -d' ' -f2`
echo "export OS_NETWORK_ID=$TENANTB_NETWORK_ID" >> /home/vagrant/openrc.user3
