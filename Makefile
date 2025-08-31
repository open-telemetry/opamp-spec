# Function to execute a command.
# Accepts command to execute as first parameter.
define exec-command
$(1)

endef

ALL_DOCS := $(shell find . -type f -name '*.md' -not -path './.github/*' -not -path './node_modules/*' | sort)

.PHONY: all
all: markdown-toc markdown-link-check markdownlint gen-proto


# This target runs markdown-toc on all files that contain
# a comment <!-- tocstop -->.
#
# The recommended way to prepate a .md file for markdown-toc is
# to add these comments:
#
#   <!-- toc -->
#   <!-- tocstop -->
.PHONY: markdown-toc
markdown-toc:
	@if ! npm ls markdown-toc; then npm ci; fi
	@for f in $(ALL_DOCS); do \
		if grep -q '<!-- tocstop -->' $$f; then \
			echo markdown-toc: processing $$f; \
			npx --no -- markdown-toc --no-first-h1 --no-stripHeadingTags -i $$f || exit 1; \
		else \
			echo markdown-toc: no TOC markers, skipping $$f; \
		fi; \
	done

.PHONY: markdown-link-check
markdown-link-check:
	@if ! npm ls markdown-link-check; then npm ci; fi
	@for f in $(ALL_DOCS); do \
		npx --no -- markdown-link-check --quiet --config .markdown_link_check_config.json $$f \
			|| exit 1; \
	done

.PHONY: markdownlint
markdownlint:
	@if ! npm ls markdownlint; then npm ci; fi
	@for f in $(ALL_DOCS); do \
		echo $$f; \
		npx --no -p markdownlint-cli markdownlint -c .markdownlint.yaml $$f \
			|| exit 1; \
	done


GENDIR := gen
# Find all .proto files.
PROTO_FILES := $(wildcard proto/*.proto)

PROTO_GEN_GO_DIR ?= $(GENDIR)/go

# When checking for protobuf breaking changes, check against the latest release tag
LAST_RELEASE_TAG := $(shell git tag --sort=committerdate | tail -1)

# Docker images for generating Protobuf files.
OTEL_DOCKER_PROTOBUF ?= otel/build-protobuf:0.14.0 # https://hub.docker.com/r/otel/build-protobuf
BUF_DOCKER ?= bufbuild/buf:1.7.0 # https://hub.docker.com/r/bufbuild/buf

BUF := docker run --rm -v "${PWD}/proto:/workspace" -w /workspace ${BUF_DOCKER}
BUF_AGAINST ?= "https://github.com/open-telemetry/opamp-spec.git\#tag=$(LAST_RELEASE_TAG),subdir=proto"

# Docker pull images.
.PHONY: docker-pull
docker-pull:
	docker pull $(OTEL_DOCKER_PROTOBUF) 
	docker pull $(BUF_DOCKER)

gen-proto: gen-go
.PHONY: gen-proto

# Generate Protobuf Go files.
.PHONY: gen-go
gen-go:
	rm -rf ./$(PROTO_GEN_GO_DIR)
	mkdir -p ./$(PROTO_GEN_GO_DIR)

	# Verify generation of Go protos
	$(foreach file,$(PROTO_FILES),$(call exec-command,docker run --rm -v${PWD}:${PWD} \
        -w${PWD} $(OTEL_DOCKER_PROTOBUF) --proto_path=${PWD}/proto/ \
        --go_out=./$(PROTO_GEN_GO_DIR) -I${PWD}/proto/ ${PWD}/$(file)))

# Breaking change detection
.PHONY: breaking-change
breaking-change:
	$(BUF) breaking --against $(BUF_AGAINST) $(BUF_FLAGS) 
