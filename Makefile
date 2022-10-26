KAFKA_VERSION    ?= $(shell grep KAFKA_VERSION VERSIONS    | cut -d= -f2)
SCALA_VERSION    ?= $(shell grep SCALA_VERSION VERSIONS    | cut -d= -f2)
RELEASE_REVISION ?= $(shell grep RELEASE_REVISION VERSIONS | cut -d= -f2)

DOCKER_REPO        ?= mccutchen/kafka-lite
DOCKER_TAG_LATEST  := $(DOCKER_REPO):latest
DOCKER_TAG_RELEASE := $(DOCKER_REPO):$(KAFKA_VERSION)-scala$(SCALA_VERSION)-rev$(RELEASE_REVISION)

build:
	DOCKER_BUILDKIT=1 docker build \
		--build-arg KAFKA_VERSION=$(KAFKA_VERSION) \
		--build-arg SCALA_VERSION=$(SCALA_VERSION) \
		-t $(DOCKER_TAG_RELEASE) \
		-t $(DOCKER_TAG_LATEST) \
		$(shell pwd)
.PHONY: image

release:
	docker buildx inspect kafka-lite &>/dev/null || docker buildx create --name kafka-lite
	docker buildx build \
		--builder kafka-lite \
		--build-arg KAFKA_VERSION=$(KAFKA_VERSION) \
		--build-arg SCALA_VERSION=$(SCALA_VERSION) \
		--push \
		--platform linux/amd64,linux/arm64 \
		-t $(DOCKER_TAG_LATEST) \
		-t $(DOCKER_TAG_RELEASE) \
		$(shell pwd)
.PHONY: release
