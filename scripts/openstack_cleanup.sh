#!/bin/bash

# Removing leftover files
rm -rf /tmp/files

# Cleanup apt's cache
apt-get autoclean
