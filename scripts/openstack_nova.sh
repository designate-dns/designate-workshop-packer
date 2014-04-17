#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient nova-compute-qemu

