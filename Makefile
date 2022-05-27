ALL_DOCS := $(shell find . -type f -name '*.md' -not -path './.github/*' -not -path './node_modules/*' | sort)

.PHONY: all
all: markdown-toc markdown-link-check markdownlint


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
