PYTHON_IMAGE ?= ghcr.io/0xalexb/ralphex-python
GO_IMAGE ?= ghcr.io/0xalexb/ralphex-go
PHP_IMAGE ?= ghcr.io/0xalexb/ralphex-php
UV_VERSION ?= 0.10.6
RUFF_VERSION ?= 0.15.3
RALPHEX_VERSION ?= latest
CLAUDE_CODE_VERSION ?= latest
CODEX_VERSION ?= latest
PYTHON_VERSIONS := 3.11 3.12 3.13
LATEST_PYTHON := 3.13
PHP_VERSIONS := 8.3 8.4 8.5
LATEST_PHP := 8.5

PLATFORMS ?= linux/amd64,linux/arm64
BUILDER_NAME ?= ralphex-builder
NATIVE_PLATFORM := linux/$(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

.PHONY: build build-python build-one build-go build-php build-one-php push push-python push-go push-php setup-buildx

setup-buildx:
	@docker buildx inspect $(BUILDER_NAME) >/dev/null 2>&1 || \
		docker buildx create --name $(BUILDER_NAME) --driver docker-container --use
	@docker buildx use $(BUILDER_NAME)

build: build-python build-go build-php

build-python: setup-buildx
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Building $(PYTHON_IMAGE):py$$ver [$(NATIVE_PLATFORM)]"; \
		TAGS="-t $(PYTHON_IMAGE):py$$ver -t $(PYTHON_IMAGE):r$(RALPHEX_VERSION)-py$$ver"; \
		if [ "$$ver" = "$(LATEST_PYTHON)" ]; then \
			TAGS="$$TAGS -t $(PYTHON_IMAGE):latest"; \
		fi; \
		if [ -n "$(VERSION)" ]; then \
			TAGS="$$TAGS -t $(PYTHON_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver"; \
		fi; \
		docker buildx build \
			--platform $(NATIVE_PLATFORM) \
			--load \
			--build-arg PYTHON_VERSION=$$ver \
			--build-arg UV_VERSION=$(UV_VERSION) \
			--build-arg RUFF_VERSION=$(RUFF_VERSION) \
			--build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) \
			--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
			--build-arg CODEX_VERSION=$(CODEX_VERSION) \
			$$TAGS \
			docker-python/ || exit 1; \
	done

build-one: setup-buildx
	@if [ -z "$(PYTHON_VERSION)" ]; then echo "Error: PYTHON_VERSION is required, e.g. make build-one PYTHON_VERSION=3.13"; exit 1; fi
	@echo "Building $(PYTHON_IMAGE):py$(PYTHON_VERSION) [$(NATIVE_PLATFORM)]"
	@TAGS="-t $(PYTHON_IMAGE):py$(PYTHON_VERSION) -t $(PYTHON_IMAGE):r$(RALPHEX_VERSION)-py$(PYTHON_VERSION)"; \
	if [ "$(PYTHON_VERSION)" = "$(LATEST_PYTHON)" ]; then \
		TAGS="$$TAGS -t $(PYTHON_IMAGE):latest"; \
	fi; \
	if [ -n "$(VERSION)" ]; then \
		TAGS="$$TAGS -t $(PYTHON_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$(PYTHON_VERSION)"; \
	fi; \
	docker buildx build \
		--platform $(NATIVE_PLATFORM) \
		--load \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg UV_VERSION=$(UV_VERSION) \
		--build-arg RUFF_VERSION=$(RUFF_VERSION) \
		--build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) \
		--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
		--build-arg CODEX_VERSION=$(CODEX_VERSION) \
		$$TAGS \
		docker-python/

build-go: setup-buildx
	@echo "Building $(GO_IMAGE):latest [$(NATIVE_PLATFORM)]"
	@TAGS="-t $(GO_IMAGE):latest -t $(GO_IMAGE):r$(RALPHEX_VERSION)"; \
	if [ -n "$(VERSION)" ]; then \
		TAGS="$$TAGS -t $(GO_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)"; \
	fi; \
	docker buildx build \
		--platform $(NATIVE_PLATFORM) \
		--load \
		--build-arg RALPHEX_GO_VERSION=$(RALPHEX_VERSION) \
		--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
		--build-arg CODEX_VERSION=$(CODEX_VERSION) \
		$$TAGS \
		docker-go/

build-php: setup-buildx
	@for ver in $(PHP_VERSIONS); do \
		echo "Building $(PHP_IMAGE):php$$ver [$(NATIVE_PLATFORM)]"; \
		TAGS="-t $(PHP_IMAGE):php$$ver -t $(PHP_IMAGE):r$(RALPHEX_VERSION)-php$$ver"; \
		if [ "$$ver" = "$(LATEST_PHP)" ]; then \
			TAGS="$$TAGS -t $(PHP_IMAGE):latest"; \
		fi; \
		if [ -n "$(VERSION)" ]; then \
			TAGS="$$TAGS -t $(PHP_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-php$$ver"; \
		fi; \
		docker buildx build \
			--platform $(NATIVE_PLATFORM) \
			--load \
			--build-arg PHP_VERSION=$$ver \
			--build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) \
			--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
			--build-arg CODEX_VERSION=$(CODEX_VERSION) \
			$$TAGS \
			docker-php/ || exit 1; \
	done

build-one-php: setup-buildx
	@if [ -z "$(PHP_VERSION)" ]; then echo "Error: PHP_VERSION is required, e.g. make build-one-php PHP_VERSION=8.5"; exit 1; fi
	@echo "Building $(PHP_IMAGE):php$(PHP_VERSION) [$(NATIVE_PLATFORM)]"
	@TAGS="-t $(PHP_IMAGE):php$(PHP_VERSION) -t $(PHP_IMAGE):r$(RALPHEX_VERSION)-php$(PHP_VERSION)"; \
	if [ "$(PHP_VERSION)" = "$(LATEST_PHP)" ]; then \
		TAGS="$$TAGS -t $(PHP_IMAGE):latest"; \
	fi; \
	if [ -n "$(VERSION)" ]; then \
		TAGS="$$TAGS -t $(PHP_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-php$(PHP_VERSION)"; \
	fi; \
	docker buildx build \
		--platform $(NATIVE_PLATFORM) \
		--load \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		--build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) \
		--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
		--build-arg CODEX_VERSION=$(CODEX_VERSION) \
		$$TAGS \
		docker-php/

push: push-python push-go push-php

push-python: setup-buildx
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Building+pushing $(PYTHON_IMAGE):py$$ver [$(PLATFORMS)]"; \
		TAGS="-t $(PYTHON_IMAGE):py$$ver -t $(PYTHON_IMAGE):r$(RALPHEX_VERSION)-py$$ver"; \
		if [ "$$ver" = "$(LATEST_PYTHON)" ]; then \
			TAGS="$$TAGS -t $(PYTHON_IMAGE):latest"; \
		fi; \
		if [ -n "$(VERSION)" ]; then \
			TAGS="$$TAGS -t $(PYTHON_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver"; \
		fi; \
		docker buildx build \
			--platform $(PLATFORMS) \
			--push \
			--build-arg PYTHON_VERSION=$$ver \
			--build-arg UV_VERSION=$(UV_VERSION) \
			--build-arg RUFF_VERSION=$(RUFF_VERSION) \
			--build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) \
			--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
			--build-arg CODEX_VERSION=$(CODEX_VERSION) \
			$$TAGS \
			docker-python/ || exit 1; \
	done

push-go: setup-buildx
	@echo "Building+pushing $(GO_IMAGE):latest [$(PLATFORMS)]"
	@TAGS="-t $(GO_IMAGE):latest -t $(GO_IMAGE):r$(RALPHEX_VERSION)"; \
	if [ -n "$(VERSION)" ]; then \
		TAGS="$$TAGS -t $(GO_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)"; \
	fi; \
	docker buildx build \
		--platform $(PLATFORMS) \
		--push \
		--build-arg RALPHEX_GO_VERSION=$(RALPHEX_VERSION) \
		--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
		--build-arg CODEX_VERSION=$(CODEX_VERSION) \
		$$TAGS \
		docker-go/

push-php: setup-buildx
	@for ver in $(PHP_VERSIONS); do \
		echo "Building+pushing $(PHP_IMAGE):php$$ver [$(PLATFORMS)]"; \
		TAGS="-t $(PHP_IMAGE):php$$ver -t $(PHP_IMAGE):r$(RALPHEX_VERSION)-php$$ver"; \
		if [ "$$ver" = "$(LATEST_PHP)" ]; then \
			TAGS="$$TAGS -t $(PHP_IMAGE):latest"; \
		fi; \
		if [ -n "$(VERSION)" ]; then \
			TAGS="$$TAGS -t $(PHP_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-php$$ver"; \
		fi; \
		docker buildx build \
			--platform $(PLATFORMS) \
			--push \
			--build-arg PHP_VERSION=$$ver \
			--build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) \
			--build-arg CLAUDE_CODE_VERSION=$(CLAUDE_CODE_VERSION) \
			--build-arg CODEX_VERSION=$(CODEX_VERSION) \
			$$TAGS \
			docker-php/ || exit 1; \
	done
