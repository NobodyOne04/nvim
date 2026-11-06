#!/usr/bin/env bash
# Installs what this config needs outside Neovim:
#   search:      ripgrep, fd, fzf          (telescope)
#   build:       git, make, C compiler     (lazy.nvim, telescope-fzf-native, treesitter parsers)
#   treesitter:  tree-sitter CLI           (compiles parsers on the `main` branch)
#   runtimes:    node/npm, go, python      (mason language servers, Copilot)
#   formatters:  stylua, black, jq, pg_format  (conform.nvim; gofmt/goimports come with go/mason)
#   git:         lazygit                   (\gg opens it in a float)
set -euo pipefail

if [[ "$OSTYPE" == darwin* ]]; then
    echo "Detected macOS"
    command -v brew >/dev/null || { echo "Error: Homebrew is not installed"; exit 1; }
    brew install neovim ripgrep fd fzf git curl wget unzip \
        tree-sitter node go python stylua black jq pgformatter lazygit
    xcode-select -p >/dev/null 2>&1 || xcode-select --install   # C compiler + make

elif [[ "$OSTYPE" == linux-gnu* ]]; then
    if command -v pacman >/dev/null; then
        echo "Detected Arch Linux"
        sudo pacman -S --needed neovim ripgrep fd fzf git curl wget unzip \
            base-devel tree-sitter-cli nodejs npm go python \
            stylua python-black jq pgformatter lazygit

    elif command -v apt >/dev/null; then
        echo "Detected Debian/Ubuntu"
        sudo apt update
        sudo apt install -y ripgrep fd-find fzf git curl wget unzip \
            build-essential nodejs npm golang python3 python3-pip black jq pgformatter
        echo "Note: install Neovim 0.12+, tree-sitter-cli, stylua and lazygit from upstream releases (apt versions are too old or missing)."

    elif command -v dnf >/dev/null; then
        echo "Detected Fedora"
        sudo dnf install -y ripgrep fd-find fzf git curl wget unzip \
            gcc make nodejs npm golang python3 black jq pgformatter neovim tree-sitter-cli
        echo "Note: install stylua with 'cargo install stylua' and lazygit from its releases if needed."

    else
        echo "Error: unsupported Linux distribution"; exit 1
    fi
else
    echo "Error: unsupported OS: $OSTYPE"; exit 1
fi

nvim --version | head -1
