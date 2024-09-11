PHASE1_OUTPUT = output-ubuntu-2004-amd64-qemu-phase1/ubuntu-2004-amd64-qemu-osinstall
PHASE2_OUTPUT = output-ubuntu-2004-amd64-qemu-phase2/ubuntu-2004-amd64-qemu-provision
SOFTLAYER_OUTPUT = output-ubuntu-2004-amd64-qemu-softlayer/ubuntu-2004-amd64-qemu-softlayer
# VAGRANT_OUTPUT = packer_ubuntu-2004-amd64-qemu-vagrant_libvirt.box
POST_OUTPUT = ubuntu-2004-amd64-nomad.vhd

COMMON_SCRIPTS = $(wildcard scripts/ubuntu-2004-amd64-qemu/common/*.sh)
PHASE1_SCRIPTS = $(wildcard scripts/ubuntu-2004-amd64-qemu/phase1/*.sh)
PHASE2_SCRIPTS = $(COMMON_SCRIPTS) $(wildcard scripts/ubuntu-2004-amd64-qemu/phase2/*.sh)
SOFTLAYER_SCRIPTS = $(COMMON_SCRIPTS) $(wildcard scripts/ubuntu-2004-amd64-qemu/softlayer/*.sh)
# VAGRANT_SCRIPTS = $(COMMON_SCRIPTS) $(wildcard scripts/ubuntu-2004-amd64-qemu/vagrant/*.sh)

COMMON_SOURCE = ubuntu-2004-amd64-qemu.pkr.hcl 
PHASE1_SOURCE = $(COMMON_SOURCE) ubuntu-2004-amd64-qemu-phase1.pkr.hcl
PHASE2_SOURCE = $(COMMON_SOURCE) ubuntu-2004-amd64-qemu-phase2.pkr.hcl
SOFTLAYER_SOURCE = $(COMMON_SOURCE) ubuntu-2004-amd64-qemu-softlayer.pkr.hcl
# VAGRANT_SOURCE = $(COMMON_SOURCE) ubuntu-2004-amd64-qemu-vagrant.pkr.hcl
POST_SOURCE = $(COMMON_SOURCE) ubuntu-2004-amd64-qemu-post.pkr.hcl

HEADLESS ?= true

.PHONY: vagrant softlayer clean # cleanbox

softlayer: $(POST_OUTPUT)
softlayer-install: $(SOFTLAYER_OUTPUT)
vagrant: $(VAGRANT_OUTPUT)

$(POST_OUTPUT) : $(SOFTLAYER_OUTPUT) $(POST_SOURCE)
	packer build -force -only=post.\* -var headless=$(HEADLESS) ./
# $(VAGRANT_OUTPUT) : $(PHASE2_OUTPUT) $(VAGRANT_SCRIPTS) $(VAGRANT_SOURCE)
# 	packer build -force -only=vagrant.\* -var headless=$(HEADLESS) ./
$(SOFTLAYER_OUTPUT) : $(PHASE2_OUTPUT) $(SOFTLAYER_SCRIPTS) $(SOFTLAYER_SOURCE)
	packer build -force -only=softlayer.\* -var headless=$(HEADLESS) ./
$(PHASE2_OUTPUT) : $(PHASE1_OUTPUT) $(PHASE2_SCRIPTS) $(PHASE2_SOURCE)
	packer build -force -only=provision.\* -var headless=$(HEADLESS) ./
$(PHASE1_OUTPUT) : $(PACKERFILE) $(PHASE1_SOURCE)
	packer build -force -only=osinstall.\* -var headless=$(HEADLESS) ./

clean: # cleanbox
	-rm ${PHASE1_OUTPUT}
	-rm ${PHASE2_OUTPUT}
	-rm ${SOFTLAYER_OUTPUT}
	-rm ${POST_OUTPUT}
	# -rm ${VAGRANT_OUTPUT}

# vagrant-libvirt doesn't manage leaves behind libvirt vol
# cleanbox: 
#	-virsh vol-delete --pool default file:-VAGRANTSLASH--VAGRANTSLASH-packer_ubuntu-2004-amd64-qemu-vagrant_libvirt.box_vagrant_box_image_0_box.img
# 	-vagrant destroy -f
# 	-vagrant box remove -f file://packer_ubuntu-2004-amd64-qemu-vagrant_libvirt.box


# vim: set ts=4 sw=4 noexpandtab:
