# nvim config — run `make help`.
#
#   make install   tools + link this repo to ~/.config/nvim + plugins + language servers
#   make update    update plugins and rewrite lazy-lock.json (commit it afterwards)

SHELL   := /bin/bash
.DEFAULT_GOAL := help

CONFIG  := $(HOME)/.config/nvim
STAMP   := $(shell date +%Y%m%d-%H%M%S)
SERVERS := pyright lua-language-server bash-language-server typescript-language-server gopls goimports

.PHONY: help install link unlink tools sync update lsp check health startup

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-9s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: tools link sync lsp ## Everything: tools, link, plugins, language servers

link: ## Link this repo to ~/.config/nvim (an existing config is moved aside, never deleted)
	@mkdir -p $(dir $(CONFIG))
	@if [ -L "$(CONFIG)" ] && [ "$$(readlink "$(CONFIG)")" = "$(CURDIR)" ]; then \
		echo "already linked: $(CONFIG) -> $(CURDIR)"; \
	else \
		if [ -e "$(CONFIG)" ] || [ -L "$(CONFIG)" ]; then \
			mv "$(CONFIG)" "$(CONFIG).bak-$(STAMP)"; echo "backed up: $(CONFIG) -> $(CONFIG).bak-$(STAMP)"; \
		fi; \
		ln -s "$(CURDIR)" "$(CONFIG)"; echo "linked: $(CONFIG) -> $(CURDIR)"; \
	fi

unlink: ## Remove the link and restore the most recent backup
	@if [ -L "$(CONFIG)" ] && [ "$$(readlink "$(CONFIG)")" = "$(CURDIR)" ]; then \
		rm "$(CONFIG)"; echo "unlinked $(CONFIG)"; \
		last=$$(ls -d $(CONFIG).bak-* 2>/dev/null | sort | tail -1); \
		if [ -n "$$last" ]; then mv "$$last" "$(CONFIG)"; echo "restored $$last"; fi; \
	else echo "$(CONFIG) is not linked to this repo; nothing to do"; fi

tools: ## Install CLI tools (ripgrep, fd, tree-sitter, node, go, formatters...)
	@./scripts/install-tools.sh

sync: ## Install plugins at the exact versions in lazy-lock.json
	nvim --headless "+Lazy! restore" +qa

update: ## Update plugins to latest and rewrite lazy-lock.json
	nvim --headless "+Lazy! sync" +qa
	@git diff --stat lazy-lock.json

lsp: ## Install language servers and goimports with mason
	nvim --headless "+MasonInstall $(SERVERS)" +qa

check: ## Start headless; show warnings, fail on startup errors
	@out=$$(nvim --headless "+qa" 2>&1); \
	[ -n "$$out" ] && echo "$$out"; \
	if echo "$$out" | grep -qE "E[0-9]+:|[Ee]rror|stack traceback"; then echo "FAIL: startup errors"; exit 1; \
	else echo "ok: no startup errors"; fi

health: ## Open :checkhealth
	nvim "+checkhealth"

startup: ## Measure startup time (5 runs)
	@for i in 1 2 3 4 5; do f=$$(mktemp); nvim --headless --startuptime $$f "+qa"; \
		grep "NVIM STARTED" $$f | awk '{printf "  %s ms\n", $$1}'; rm -f $$f; done
