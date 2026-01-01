ALPINE_VERSION := 3.24.1
ALPINE_REPO_BRANCH := 3.24
ALPINE_BASE_URL := https://dl-cdn.alpinelinux.org/alpine/v$(ALPINE_REPO_BRANCH)/releases/x86_64
ALPINE_ISO := alpine-virt-$(ALPINE_VERSION)-x86_64.iso

IMAGE_DIR := images/alpine/base
IMAGE := $(IMAGE_DIR)/alpine-base.qcow2
TMP := $(IMAGE).tmp

.PHONY: base clean

base: $(IMAGE)

$(IMAGE): $(IMAGE_DIR)/$(ALPINE_ISO)
	rm -f $(TMP)
	qemu-img create -f qcow2 $(TMP) 8G
	if ! scripts/install-base.sh $(IMAGE_DIR)/$(ALPINE_ISO) $(TMP) $(ALPINE_REPO_BRANCH); then \
		rm -f $(TMP); \
		exit 1; \
	fi
	mv $(TMP) $@

$(IMAGE_DIR)/$(ALPINE_ISO):
	mkdir -p $(IMAGE_DIR)
	curl -fSL -o $@ $(ALPINE_BASE_URL)/$(ALPINE_ISO)
	curl -fSL -o $@.sha256 $(ALPINE_BASE_URL)/$(ALPINE_ISO).sha256
	cd $(IMAGE_DIR) && sha256sum -c $(ALPINE_ISO).sha256

clean:
	rm -f $(IMAGE) $(TMP)
