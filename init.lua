-- Neovim Configuration
-- Modular setup for better maintainability

-- Speed up Lua module loading via the built-in bytecode cache (Neovim 0.9+).
-- Must run before any other require().
vim.loader.enable()

-- Load core configuration
require('config.options').setup()
require('config.keymaps').setup()
require('config.autocmds').setup()

-- Bootstrap and setup packer
local is_bootstrap = require('config.packer').setup()
if is_bootstrap then
  return -- Exit if bootstrapping
end

-- Load plugin configurations (with safe loading to handle first run)
local function safe_require_setup(module_name)
  local ok, module = pcall(require, module_name)
  if ok and module.setup then
    local setup_ok, err = pcall(module.setup)
    if not setup_ok then
      vim.notify('Error setting up ' .. module_name .. ': ' .. tostring(err), vim.log.levels.WARN)
    end
  end
end

safe_require_setup('plugins.theme')
safe_require_setup('plugins.telescope')
safe_require_setup('plugins.treesitter')
safe_require_setup('plugins.lsp')
safe_require_setup('plugins.completion')
safe_require_setup('plugins.ui')
safe_require_setup('plugins.windsurf')
safe_require_setup('plugins.claude-code')
safe_require_setup('plugins.git-worktree')
safe_require_setup('plugins.dap')

-- vim: ts=2 sts=2 sw=2 et
