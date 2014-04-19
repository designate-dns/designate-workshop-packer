all: clean files packer

clean:
	rm -rf output-* files.tar.gz

files:
	tar -czf files.tar.gz files

packer:
	./packer/packer build template.json

.PHONY: all clean files packer
