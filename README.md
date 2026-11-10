# Ultra Vim Station

## Quick Start

Run the installation script to start adventuring:

```bash
./install.sh
```

## Installed Dependencies & Plugins

The installation script (`install.sh`) automatically sets up the following components:

### System Dependencies
*   **Core:** `neovim`, `tmux`, `git`, `make` (or `base-devel`)
*   **Runtime:** `go`, `node` (npm)
*   **Utilities:** `ripgrep`, `fd`, `jq`
*   **Fonts:** `Hack Nerd Font`

### Language Servers & Tools
*   **Go:** `gopls`, `golangci-lint`, `fieldalignment`, `go-swagger`
*   **TypeScript:** `typescript-language-server`
*   **Bash:** `bash-language-server`
*   **JSON:** `vscode-langservers-extracted` (via `jsonls`)

### Neovim Plugins
The setup bootstraps `packer.nvim` and installs the following plugins:

*   **Package Management:** `packer.nvim`
*   **LSP & Completion:** `nvim-lspconfig`, `nvim-cmp`, `LuaSnip`, `mason.nvim`, `fidget.nvim`, `neodev.nvim`
*   **Treesitter:** `nvim-treesitter`, `nvim-treesitter-textobjects`
*   **Git Integration:** `vim-fugitive`, `gitsigns.nvim`, `git-worktree.nvim`, `git-blame.nvim`
*   **Debugging:** `nvim-dap`, `nvim-dap-ui`, `nvim-dap-go`, `nvim-dap-vscode-js`
*   **AI Assistance:** `copilot.lua`, `claude-code.nvim`, `augment.vim`
*   **Navigation & UI:** `nerdtree`, `lualine.nvim`, `telescope.nvim`, `onedark.nvim` (Theme)
*   **Formatting:** `conform.nvim` (Go)
