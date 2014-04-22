#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient nova-compute-qemu

cp /tmp/files/nova.conf /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage db sync" nova

dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)

service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
service nova-compute restart

sleep 10

source /home/vagrant/openrc.admin

nova flavor-create --is-public True m1.xtiny 200 256 1 1
nova flavor-create --is-public True m1.xxtiny 201 128 1 1
nova flavor-create --is-public True m1.xxxtiny 202 64 1 1

nova keypair-add --pub-key /home/vagrant/.ssh/authorized_keys vagrant

source /home/vagrant/openrc.user

nova keypair-add --pub-key /home/vagrant/.ssh/authorized_keys vagrant
