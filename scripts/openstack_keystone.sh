#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install keystone

cp /tmp/files/etc/keystone/keystone.conf /etc/keystone/keystone.conf

rm /var/lib/keystone/keystone.db

su -s /bin/sh -c "keystone-manage db_sync" keystone

service keystone restart

export OS_SERVICE_TOKEN=zEDreswACrAChequSWA5EtremawAwaXe
export OS_SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0

# Roles
keystone role-create --name=service
keystone role-create --name=admin

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

keystone user-create --name=user --pass=password --email=user@designate-workshop.com
keystone tenant-create --name=user --description="User Tenant"
keystone user-role-add --user=user --tenant=user --role=_member_

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
