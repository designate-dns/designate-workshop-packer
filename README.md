Requirements
============

* GNU Make (Needed only to build the VM - You can execute the steps by hand if you don't/can't have Make installed)
* Packer 0.5.2 (Needed only to build the VM)
* VirtualBox 4.3 (Needed to build and run the VM)
* Vagrant 1.5.3 (Needed to run the VM)

Building the VM
===============

Simply type "make". Packer will be downloaded+installed, and the build will begin. When the VirtualBox GUI pops up showing the VM - Do not click/type anything - packer will interact with the VM.

Customizing the VM
==================

Add a new script file to the "scripts" directory, and add a reference to it in the template.json file. The contents of the "files" folder will be available on the VM as /tmp/files.

The end result will be a VirtualBox VM in the 'output-*' folder, and a Vagrant Box in the '*.box' file.