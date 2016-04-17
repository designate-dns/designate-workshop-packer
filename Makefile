UNAME_S := $(shell uname -s)

all: packer clean files build

packer.zip:
ifeq ($(UNAME_S),Linux)
	wget -O packer.zip https://releases.hashicorp.com/packer/0.10.0/packer_0.10.0_linux_amd64.zip
endif
ifeq ($(UNAME_S),Darwin)
	wget -O packer.zip https://releases.hashicorp.com/packer/0.10.0/packer_0.10.0_darwin_amd64.zip
endif

packer: packer.zip
	unzip -d packer packer.zip

clean:
	rm -rf output-* files.tar.gz

files:
	tar -czf files.tar.gz files

build: packer files
	./packer/packer build template.json

debug: packer files
	./packer/packer build -debug template.json

.PHONY: all clean files build
