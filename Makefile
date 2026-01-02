ALPINE_VERSION := 3.24.1
ALPINE_REPO_BRANCH := 3.24
ALPINE_BASE_URL := https://dl-cdn.alpinelinux.org/alpine/v$(ALPINE_REPO_BRANCH)/releases/x86_64
ALPINE_ISO := alpine-virt-$(ALPINE_VERSION)-x86_64.iso

IMAGE_DIR := images/alpine/base
IMAGE := $(IMAGE_DIR)/alpine-base.qcow2
TMP := $(IMAGE).tmp

K3S_VERSION := v1.36.3+k3s1
K3S_URL := https://github.com/k3s-io/k3s/releases/download/$(subst +,%2B,$(K3S_VERSION))

COMMON_IMAGE_DIR := images/alpine/common
COMMON_IMAGE := $(COMMON_IMAGE_DIR)/alpine-common.qcow2
COMMON_TMP := $(COMMON_IMAGE).tmp

.PHONY: base common clean

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

common: $(COMMON_IMAGE)

$(COMMON_IMAGE): $(IMAGE) scripts/install-common.sh
	mkdir -p $(COMMON_IMAGE_DIR)
	curl -fSL -o /tmp/k3s-sha256.txt $(K3S_URL)/sha256sum-amd64.txt
	K3S_SHA256=$$(grep ' k3s$$' /tmp/k3s-sha256.txt | cut -d' ' -f1) && \
	rm -f $(COMMON_TMP) && \
	qemu-img create -f qcow2 -F qcow2 -b $(abspath $(IMAGE)) $(COMMON_TMP) && \
	if scripts/install-common.sh $(COMMON_TMP) $(K3S_URL)/k3s "$$K3S_SHA256"; then \
		mv $(COMMON_TMP) $@; \
	else \
		rm -f $(COMMON_TMP); \
		exit 1; \
	fi

clean:
	rm -f $(IMAGE) $(TMP) $(COMMON_IMAGE) $(COMMON_TMP)
