DOCKER_IMAGE ?= ghcr.io/0xalexb/ralphex-python
UV_VERSION ?= 0.10.6
RUFF_VERSION ?= 0.15.3
PYTHON_VERSIONS := 3.11 3.12 3.13
LATEST_VERSION := 3.13

.PHONY: build build-one push

build:
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Building $(DOCKER_IMAGE):$$ver"; \
		docker build --build-arg PYTHON_VERSION=$$ver --build-arg UV_VERSION=$(UV_VERSION) --build-arg RUFF_VERSION=$(RUFF_VERSION) -t $(DOCKER_IMAGE):$$ver . || exit 1; \
	done
	docker tag $(DOCKER_IMAGE):$(LATEST_VERSION) $(DOCKER_IMAGE):latest

build-one:
	@if [ -z "$(PYTHON_VERSION)" ]; then echo "Error: PYTHON_VERSION is required, e.g. make build-one PYTHON_VERSION=3.13"; exit 1; fi
	docker build --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg UV_VERSION=$(UV_VERSION) --build-arg RUFF_VERSION=$(RUFF_VERSION) -t $(DOCKER_IMAGE):$(PYTHON_VERSION) .

push:
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Pushing $(DOCKER_IMAGE):$$ver"; \
		docker push $(DOCKER_IMAGE):$$ver || exit 1; \
	done
	@if docker image inspect $(DOCKER_IMAGE):latest >/dev/null 2>&1; then \
		docker push $(DOCKER_IMAGE):latest; \
	else \
		echo "Skipping latest: tag not found (run 'make build' to create it)"; \
	fi
