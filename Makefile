# nvim config — run `make help`.
#
#   make install   tools + link this repo to ~/.config/nvim + plugins + language servers
#   make update    update plugins and rewrite lazy-lock.json (commit it afterwards)
#   make notebook  Jupyter support: python host for molten + jupytext
#   make kernel VENV=path/to/.venv   register a project venv as a Jupyter kernel

SHELL   := /bin/bash
.DEFAULT_GOAL := help

CONFIG  := $(HOME)/.config/nvim
STAMP   := $(shell date +%Y%m%d-%H%M%S)
PYHOST  := $(HOME)/.local/share/nvim/python-host
SERVERS := pyright lua-language-server bash-language-server typescript-language-server gopls goimports delve

.PHONY: help install link unlink tools sync update lsp notebook kernel check health startup

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-9s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: tools link sync lsp notebook ## Everything: tools, link, plugins, language servers, notebooks

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

sync: ## Install plugins at the exact versions in lazy-lock.json, then compile treesitter parsers
	nvim --headless "+Lazy! restore" "+Lazy! clean" +qa
	@nvim --headless -c "luafile scripts/blink-fuzzy.lua"
	@nvim --headless -c "luafile scripts/ts-install.lua"

update: ## Update plugins to latest and rewrite lazy-lock.json
	nvim --headless "+Lazy! sync" +qa
	@nvim --headless -c "luafile scripts/blink-fuzzy.lua"
	@git diff --stat lazy-lock.json

lsp: ## Install language servers and goimports with mason
	MASON_PKGS="$(SERVERS)" nvim --headless -c "luafile scripts/mason-install.lua"

notebook: ## Jupyter: python host for molten (pynvim, jupyter_client) + jupytext CLI
	uv venv --allow-existing --python 3.12 "$(PYHOST)"
	uv pip install --python "$(PYHOST)/bin/python" --upgrade pynvim jupyter_client nbformat pillow
	uv tool install --upgrade jupytext
	nvim --headless "+Lazy! load molten-nvim" +UpdateRemotePlugins +qa
	@echo "ok: notebook support installed (register a kernel with: make kernel VENV=path/to/.venv)"

kernel: ## Register a project venv as a Jupyter kernel: make kernel VENV=path/to/.venv [NAME=name]
	@[ -n "$(VENV)" ] || { echo "usage: make kernel VENV=path/to/.venv [NAME=name]"; exit 1; }
	uv pip install --python "$(VENV)/bin/python" ipykernel
	"$(VENV)/bin/python" -m ipykernel install --user \
		--name "$(or $(NAME),$(notdir $(patsubst %/,%,$(dir $(abspath $(VENV))))))"

check: ## Start headless, then load every plugin and open a file per language; fail on errors
	@out=$$(nvim --headless "+qa" 2>&1); \
	[ -n "$$out" ] && echo "$$out"; \
	if echo "$$out" | grep -qE "E[0-9]+:|[Ee]rror|stack traceback"; then echo "FAIL: startup errors"; exit 1; \
	else echo "ok: no startup errors"; fi
	@out=$$(nvim --headless -c "luafile scripts/check.lua" 2>&1); \
	[ -n "$$out" ] && echo "$$out"; \
	if echo "$$out" | grep -qE "E[0-9]+:|[Ee]rror|stack traceback"; then echo "FAIL: errors with all plugins loaded"; exit 1; \
	else echo "ok: all plugins load, no errors opening files"; fi

health: ## Open :checkhealth
	nvim "+checkhealth"

startup: ## Measure startup time (5 runs)
	@for i in 1 2 3 4 5; do f=$$(mktemp); nvim --headless --startuptime $$f "+qa"; \
		grep "NVIM STARTED" $$f | awk '{printf "  %s ms\n", $$1}'; rm -f $$f; done
