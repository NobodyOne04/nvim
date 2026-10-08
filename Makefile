.PHONY: install nvim lsp tools

install: nvim lsp tools

nvim:
	@echo "Installing Neovim config..."
	mkdir -p ~/.config
	ln -sfn $(CURDIR) ~/.config/nvim

lsp:
	@echo "Installing LSP servers..."
	nvim --headless "+MasonInstall pyright lua-language-server bash-language-server typescript-language-server" +qa

tools:
	@echo "Installing CLI tools..."
	sudo pacman -S --needed \
		ripgrep \
		fd \
		fzf \
		git \
		curl \
		wget \
		unzip

