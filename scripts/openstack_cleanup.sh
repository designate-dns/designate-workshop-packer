#!/bin/bash

# Removing leftover files
rm -rf /tmp/files /tmp/files.tar.gz

# Cleanup anything we don't need
apt-get --yes autoremove

# Cleanup apt's cache
apt-get autoclean
