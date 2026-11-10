# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular Neovim configuration focused on Go development, LSP integration, and productivity. The configuration uses Packer.nvim as the package manager and follows a structured approach with separate modules for different concerns.

## Key Architecture

### Module Structure
- **Entry Point**: `init.lua` - orchestrates the loading of all configuration modules
- **Core Config**: `lua/config/` - contains fundamental Neovim settings
  - `options.lua` - Neovim options and settings
  - `keymaps.lua` - general keymappings  
  - `autocmds.lua` - auto commands and highlights
  - `packer.lua` - package manager setup and plugin declarations
- **Plugin Config**: `lua/plugins/` - contains plugin-specific configurations that are loaded after packer setup

### Plugin Configuration Pattern
Each plugin module in `lua/plugins/` follows the pattern:
```lua
local M = {}
function M.setup()
  -- plugin configuration
end
return M
```

### LSP Architecture
- Uses `mason.nvim` for automatic language server installation (except gopls which uses system version)
- LSP configuration is centralized in `lua/plugins/lsp.lua`
- Uses Telescope for LSP navigation (definitions, references, symbols)
- Go development uses system `gopls` rather than Mason-managed version

## Common Development Commands

### Package Management
- `:PackerSync` - Update and install plugins
- `:PackerStatus` - Check plugin status
- `:PackerClean` - Remove unused plugins

### LSP Commands
- `:LspInfo` - Show LSP client information
- `:LspRestart` - Restart LSP client
- `:Mason` - Open Mason UI for language server management

### Key Bindings Reference
- Leader key: `<Space>`
- LSP navigation: `gd` (definition), `gr` (references), `gI` (implementation)
- Telescope: `<leader>sf` (find files), `<leader>sg` (live grep), `<leader><space>` (buffers)
- Go test files (`*test.go`) are dimmed in NERDTree and excluded from `<leader>sf`/`<leader>sg`/`<leader>sw` and from `gr`/`gI`/`gW` (LSP references, implementations, workspace symbols — but not `gd`/`gy`, and not while editing a test file); `<leader>st` (or `:TelescopeGoTests`) toggles them back in
- Diagnostics: `<leader>ne` (next error), `<leader>e` (open diagnostic float)
- Git: `gn` (next hunk), `gpi` (preview hunk inline)

## Development Setup

### Dependencies
- **Go**: Required for Go development features and gopls
- **make**: Required for telescope-fzf-native compilation
- **git**: Required for package management and git integrations

### First-time Setup
The configuration automatically bootstraps Packer and installs plugins on first run. If plugins fail to install:
1. Run `:PackerSync` 
2. Restart Neovim
3. Check `:checkhealth` for any missing dependencies

### Modifying Configuration
- **Adding plugins**: Edit `lua/config/packer.lua` and run `:PackerSync`
- **LSP servers**: Add to the `servers` table in `lua/plugins/lsp.lua`
- **Keymaps**: Modify `lua/config/keymaps.lua` for general keymaps or specific plugin files for plugin-specific bindings
- **Options**: Edit `lua/config/options.lua` for Neovim settings

## Troubleshooting

### Common Issues
- **LSP not working**: Use `<leader>li` to check LSP status, ensure Go is in PATH for gopls
- **Plugin issues**: Run `:PackerSync` to update plugins
- **Performance issues**: Check `:checkhealth` for optimization suggestions
- **Telescope not finding files**: Ensure `make` is installed for fzf-native

### System Requirements
- Neovim 0.8+ (inlay hints require 0.10+)
- Go toolchain for Go development
- Node.js for some LSP servers managed by Mason