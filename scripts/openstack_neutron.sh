#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get --yes install neutron-server neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms neutron-l3-agent neutron-dhcp-agent
