UNAME_S := $(shell uname -s)

all: packer clean files build

packer.zip:
ifeq ($(UNAME_S),Linux)
	wget -O packer.zip https://dl.bintray.com/mitchellh/packer/0.5.2_linux_amd64.zip
endif
ifeq ($(UNAME_S),Darwin)
	wget -O packer.zip https://dl.bintray.com/mitchellh/packer/0.5.2_darwin_amd64.zip
endif

packer: packer.zip
	unzip -d packer packer.zip

clean:
	rm -rf output-* files.tar.gz

files:
	tar -czf files.tar.gz files

build:
	./packer/packer build template.json

.PHONY: all clean files build
