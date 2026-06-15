# Function to execute a command.
# Accepts command to execute as first parameter.
define exec-command
$(1)

endef

ALL_DOCS := $(shell find . -type f -name '*.md' -not -path './.github/*' -not -path './node_modules/*' | sort)

.PHONY: all
all: markdown-toc markdown-link-check markdownlint gen-proto

.PHONY: markdown-toc
markdown-toc:
	@if ! npm ls doctoc; then npm ci; fi
	npx --no -- doctoc . --update-only --mintocitems 1 --toc-pragma-style compact --notitle --entryprefix='-,*,+' || exit 1;

.PHONY: markdown-toc-check
markdown-toc-check:
	@if ! npm ls doctoc; then npm ci; fi
	npx --no -- doctoc . --update-only --mintocitems 1 --toc-pragma-style compact --notitle --entryprefix='-,*,+' --dryrun || exit 1;

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
PROTO_FILES := $(wildcard proto/opamp/v1/*.proto)

PROTO_GEN_GO_DIR ?= $(GENDIR)/go
PROTO_GEN_CSHARP_DIR ?= $(GENDIR)/csharp

# https://github.com/open-telemetry/build-tools/releases
OTEL_DOCKER_PROTOBUF ?= otel/build-protobuf:0.25.0

# Docker pull image.
.PHONY: docker-pull
docker-pull:
	docker pull $(OTEL_DOCKER_PROTOBUF)

gen-proto: gen-go gen-csharp
.PHONY: gen-proto

# Generate Protobuf Go files.
.PHONY: gen-go
gen-go:
	rm -rf ./$(PROTO_GEN_GO_DIR)
	mkdir -p ./$(PROTO_GEN_GO_DIR)

	# Verify generation of Go protos
	$(foreach file,$(PROTO_FILES),$(call exec-command,docker run --rm -u $(shell id -u):$(shell id -g) -v${PWD}:${PWD} \
        -w${PWD} $(OTEL_DOCKER_PROTOBUF) --proto_path=${PWD}/proto/ \
        --go_out=./$(PROTO_GEN_GO_DIR) -I${PWD}/proto/ ${PWD}/$(file)))

# Generate Protobuf C# files.
.PHONY: gen-csharp
gen-csharp:
	rm -rf ./$(PROTO_GEN_CSHARP_DIR)
	mkdir -p ./$(PROTO_GEN_CSHARP_DIR)

	# Verify generation of C# protos
	$(foreach file,$(PROTO_FILES),$(call exec-command,docker run --rm -u $(shell id -u):$(shell id -g) -v${PWD}:${PWD} \
        -w${PWD} $(OTEL_DOCKER_PROTOBUF) --proto_path=${PWD}/proto/ \
        --csharp_out=./$(PROTO_GEN_CSHARP_DIR) -I${PWD}/proto/ ${PWD}/$(file)))