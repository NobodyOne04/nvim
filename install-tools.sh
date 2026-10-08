#!/usr/bin/env bash

set -e

TOOLS=(
    ripgrep
    fd
    fzf
    git
    curl
    wget
    unzip
)

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"

    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew is not installed"
        exit 1
    fi

    brew install "${TOOLS[@]}"

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then

    if command -v pacman >/dev/null 2>&1; then
        echo "Detected Arch Linux"
        sudo pacman -S --needed "${TOOLS[@]}"

    elif command -v apt >/dev/null 2>&1; then
        echo "Detected Debian/Ubuntu"

        sudo apt update
        sudo apt install -y \
            ripgrep \
            fd-find \
            fzf \
            git \
            curl \
            wget \
            unzip

    elif command -v dnf >/dev/null 2>&1; then
        echo "Detected Fedora"

        sudo dnf install -y \
            ripgrep \
            fd-find \
            fzf \
            git \
            curl \
            wget \
            unzip

    else
        echo "Error: unsupported Linux distribution"
        exit 1
    fi

else
    echo "Error: unsupported OS: $OSTYPE"
    exit 1
fi
