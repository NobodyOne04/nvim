.PHONY: install nvim tools lsp

install: nvim tools lsp

nvim:
	@echo "→ Installing Neovim config..."
	mkdir -p ~/.config
	ln -sfn "$(CURDIR)" ~/.config/nvim

tools:
	@echo "→ Installing CLI tools..."
	@./scripts/install-tools.sh

lsp:
	@echo "→ Installing LSP servers..."
	nvim --headless \
		"+MasonInstall pyright lua-language-server bash-language-server typescript-language-server" \
		+qa
