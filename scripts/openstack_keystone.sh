#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install keystone

cp /tmp/files/keystone.conf /etc/keystone/keystone.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone

service keystone restart

sleep 5

export OS_SERVICE_TOKEN=zEDreswACrAChequSWA5EtremawAwaXe
export OS_SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0

# Roles
keystone role-create --name=service
keystone role-create --name=admin
keystone role-create --name=_member_

# Users/Tenants
keystone user-create --name=service --pass=password --email=service@designate-workshop.com
keystone tenant-create --name=service --description="Service Tenant"
keystone user-role-add --user=service --tenant=service --role=service
keystone user-role-add --user=service --tenant=service --role=admin
keystone user-role-add --user=service --tenant=service --role=_member_

keystone user-create --name=admin --pass=password --email=admin@designate-workshop.com
keystone tenant-create --name=admin --description="Admin Tenant"
keystone user-role-add --user=admin --tenant=admin --role=admin
keystone user-role-add --user=admin --tenant=admin --role=_member_

keystone user-create --name=user1 --pass=password --email=user1@designate-workshop.com
keystone tenant-create --name=tenant1 --description="Tenant 1"
keystone user-role-add --user=user1 --tenant=tenant1 --role=_member_

keystone user-create --name=user2 --pass=password --email=user2@designate-workshop.com
keystone tenant-create --name=tenant2 --description="Tenant 2"
keystone user-role-add --user=user2 --tenant=tenant2 --role=_member_

# Services
keystone service-create --name=keystone --type=identity --description="OpenStack Identity Service"
keystone service-create --name=glance --type=image --description="OpenStack Image Service"
keystone service-create --name=nova --type=compute --description="OpenStack Compute Service"
keystone service-create --name=neutron --type=network --description="OpenStack Networking Service"

# Endpoints
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl=http://127.0.0.1:5000/v2.0 \
  --internalurl=http://127.0.0.1:5000/v2.0 \
  --adminurl=http://127.0.0.1:35357/v2.0

keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ image / {print $2}') \
  --publicurl=http://127.0.0.1:9292 \
  --internalurl=http://127.0.0.1:9292 \
  --adminurl=http://127.0.0.1:9292

keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ compute / {print $2}') \
  --publicurl='http://127.0.0.1:8774/v2/%(tenant_id)s' \
  --internalurl='http://127.0.0.1:8774/v2/%(tenant_id)s' \
  --adminurl='http://127.0.0.1:8774/v2/%(tenant_id)s'

keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ network / {print $2}') \
  --publicurl=http://127.0.0.1:9696 \
  --internalurl=http://127.0.0.1:9696 \
  --adminurl=http://127.0.0.1:9696

# OpenRC Files
cp /tmp/files/openrc.admin /home/vagrant/openrc.admin
cp /tmp/files/openrc.user1 /home/vagrant/openrc.user1
cp /tmp/files/openrc.user2 /home/vagrant/openrc.user2
