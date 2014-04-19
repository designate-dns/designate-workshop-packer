#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient nova-compute-qemu

cp /tmp/files/etc/nova/nova.conf /etc/nova/nova.conf

rm /var/lib/nova/nova.sqlite

su -s /bin/sh -c "nova-manage db sync" nova

dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)

service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
service nova-compute restart
