#!/bin/bash

# install.sh
# Unified setup for Neovim configuration on macOS and Arch Linux
# Supports: Go, TypeScript, Bash, and JSON LSP

set -e

echo "Starting Neovim setup..."

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo "Detected OS: $OS"

if [[ "$OS" == "unknown" ]]; then
    echo "Error: Unsupported operating system"
    echo "This script supports macOS and Arch Linux only."
    exit 1
fi

# macOS setup
setup_macos() {
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for the current session
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "Homebrew is already installed."
    fi

    # Install system dependencies
    echo "Installing system dependencies..."
    brew install neovim go ripgrep fd node git make

    # Install Nerd Font
    echo "Installing Hack Nerd Font..."
    brew tap homebrew/cask-fonts 2>/dev/null || true
    brew install --cask font-hack-nerd-font || echo "Font install skipped or already exists."
}

# Arch Linux setup
setup_arch() {
    # Update package database
    echo "Updating package database..."
    sudo pacman -Sy

    # Install system dependencies
    echo "Installing system dependencies..."
    sudo pacman -S --noconfirm --needed neovim go ripgrep fd nodejs npm git base-devel unzip

    # Install Nerd Font
    echo "Installing Hack Nerd Font..."
    sudo pacman -S --noconfirm --needed ttf-hack-nerd
}

# Install global language servers (common to both platforms)
install_language_servers() {
    echo "Installing global language servers..."

    # Ensure GOPATH/bin is in PATH
    export PATH="$PATH:$(go env GOPATH)/bin"

    # Go LSP (gopls) - used as system binary by config
    echo "  Installing gopls..."
    go install golang.org/x/tools/gopls@latest

    # golangci-lint v2 - linter aggregator for Go
    echo "  Installing golangci-lint v2..."
    go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest

    # fieldalignment - struct field alignment analyzer
    echo "  Installing fieldalignment..."
    go install golang.org/x/tools/go/analysis/passes/fieldalignment/cmd/fieldalignment@latest

    # TypeScript LSP
    echo "  Installing typescript-language-server..."
    if [[ "$OS" == "arch" ]]; then
        sudo npm install -g typescript typescript-language-server
    else
        npm install -g typescript typescript-language-server
    fi

    # Bash LSP
    echo "  Installing bash-language-server..."
    if [[ "$OS" == "arch" ]]; then
        sudo npm install -g bash-language-server
    else
        npm install -g bash-language-server
    fi

    # JSON LSP (vscode-langservers-extracted includes jsonls)
    echo "  Installing vscode-langservers-extracted (JSON LSP)..."
    if [[ "$OS" == "arch" ]]; then
        sudo npm install -g vscode-langservers-extracted
    else
        npm install -g vscode-langservers-extracted
    fi
}

# Link configuration
link_config() {
    echo "Linking configuration..."
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG_DIR="$HOME/.config/nvim"

    if [ -L "$CONFIG_DIR" ]; then
        CURRENT_LINK=$(readlink "$CONFIG_DIR")
        if [ "$CURRENT_LINK" == "$REPO_DIR" ]; then
            echo "Configuration already linked correctly."
        else
            echo "Warning: $CONFIG_DIR is linked to $CURRENT_LINK."
            echo "Please remove it manually if you want to link this repo."
            return 1
        fi
    elif [ -d "$CONFIG_DIR" ]; then
        echo "Backing up existing nvim config to $CONFIG_DIR.bak"
        mv "$CONFIG_DIR" "$CONFIG_DIR.bak"
        ln -s "$REPO_DIR" "$CONFIG_DIR"
        echo "Linked $REPO_DIR to $CONFIG_DIR"
    else
        mkdir -p "$HOME/.config"
        ln -s "$REPO_DIR" "$CONFIG_DIR"
        echo "Linked $REPO_DIR to $CONFIG_DIR"
    fi
}

# Bootstrap Neovim plugins
bootstrap_plugins() {
    echo "Bootstrapping Neovim plugins..."
    echo "This may take a minute. Please wait."

    # First run: Let Neovim bootstrap Packer and install plugins
    # The init.lua will detect fresh install, clone packer, and call packer.sync()
    # We wait for the PackerComplete event before exiting
    nvim --headless \
        -c "autocmd User PackerComplete quitall" \
        -c "lua require('config.packer').setup()" \
        +qa 2>/dev/null || true

    # Give it a moment to settle
    sleep 2

    # Second run: Ensure everything is synced
    # At this point Packer should be installed
    nvim --headless -c "PackerSync" 2>/dev/null &
    NVIM_PID=$!

    # Wait for sync to complete (with timeout)
    TIMEOUT=120
    ELAPSED=0
    while kill -0 $NVIM_PID 2>/dev/null; do
        sleep 1
        ELAPSED=$((ELAPSED + 1))
        if [ $ELAPSED -ge $TIMEOUT ]; then
            echo "Plugin installation timed out. Continuing..."
            kill $NVIM_PID 2>/dev/null || true
            break
        fi
    done

    echo "Plugin installation completed."
}

# Main installation flow
main() {
    echo "=================================="
    echo "  Neovim Configuration Installer"
    echo "=================================="
    echo ""

    # Platform-specific setup
    if [[ "$OS" == "macos" ]]; then
        setup_macos
    elif [[ "$OS" == "arch" ]]; then
        setup_arch
    fi

    # Common setup
    install_language_servers
    link_config
    bootstrap_plugins

    echo ""
    echo "=================================="
    echo "  Setup complete!"
    echo "=================================="
    echo ""
    echo "Next steps:"
    echo "  1. Ensure your terminal is using 'Hack Nerd Font'."
    echo "  2. Run 'nvim' to start."
    echo "  3. Inside nvim, run ':checkhealth' to verify everything is working."
    echo ""
    echo "If plugins didn't install correctly, run ':PackerSync' inside nvim."
}

main "$@"
