all: files packer

files:
	tar -czf files.tar.gz files

packer:
	./packer/packer build template.json

.PHONY: all files packer
