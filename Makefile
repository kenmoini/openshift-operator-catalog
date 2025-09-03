# CATALOG_VERSION defines the Catalog version
# Update this value when you upgrade the version of your Catalog Distribution.
# To re-generate a bundle for another specific version without changing the standard setup, you can:
# - use the CATALOG_VERSION as arg of the bundle target (e.g make catalog-build CATALOG_VERSION=0.0.2)
# - use environment variables to overwrite this value (e.g export CATALOG_VERSION=0.0.2)
CATALOG_VERSION ?= stable

# The image tag given to the resulting catalog image (e.g. make catalog-build CATALOG_IMG=example.com/operator-catalog:v0.2.0).
CATALOG_IMG ?= quay.io/kenmoini/openshift-operator-catalog:$(CATALOG_VERSION)

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= podman

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

# Setup functions
.PHONY: opm
OPM = $(LOCALBIN)/opm
opm: ## Download opm locally if necessary.
ifeq (,$(wildcard $(OPM)))
ifeq (,$(shell which opm 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p $(dir $(OPM)) ;\
	OS=$(shell go env GOOS) && ARCH=$(shell go env GOARCH) && \
	curl -sSLo $(OPM) https://github.com/operator-framework/operator-registry/releases/download/v1.55.0/$${OS}-$${ARCH}-opm ;\
	chmod +x $(OPM) ;\
	}
else
OPM = $(shell which opm)
endif
endif

# A comma-separated list of bundle images (e.g. make catalog-build BUNDLE_IMAGES=example.com/operator-bundle:v0.1.0,example.com/operator-bundle:v0.2.0).
# These images MUST exist in a registry and be pull-able.
#BUNDLE_IMAGES ?= $(BUNDLE_IMG)
BUNDLE_IMAGES := $(shell ./hack/processBundles.sh -q)

.PHONY: print-bundle-images
print-bundle-images:
	@echo $(BUNDLE_IMAGES)

# Set CATALOG_BASE_IMG to an existing catalog image tag to add $BUNDLE_IMAGES to that image.
ifneq ($(origin CATALOG_BASE_IMG), undefined)
FROM_INDEX_OPT := --from-index $(CATALOG_BASE_IMG)
endif

# Build a catalog image by adding bundle images to an empty catalog using the operator package manager tool, 'opm'.
# This recipe invokes 'opm' in 'semver' bundle add mode. For more information on add modes, see:
# https://github.com/operator-framework/community-operators/blob/7f1438c/docs/packaging-operator.md#updating-your-existing-operator
.PHONY: catalog-build
catalog-build: opm ## Build a catalog image.
	$(OPM) index add --container-tool $(CONTAINER_TOOL) --mode semver --tag $(CATALOG_IMG) --bundles $(BUNDLE_IMAGES) $(FROM_INDEX_OPT)

.PHONY: catalog-build-dockerfile
catalog-build-dockerfile: opm ## Build a catalog image and output the dockerfile.
	$(OPM) index add --container-tool $(CONTAINER_TOOL) --out-dockerfile Dockerfile.$(CATALOG_VERSION) --mode semver --tag $(CATALOG_IMG) --bundles $(BUNDLE_IMAGES) $(FROM_INDEX_OPT)

# Push the catalog image.
.PHONY: catalog-push
catalog-push: ## Push a catalog image.
	$(MAKE) docker-push IMG=$(CATALOG_IMG)

