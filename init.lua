-- Neovim Configuration
-- Modular setup for better maintainability

-- Load core configuration
require('config.options').setup()
require('config.keymaps').setup()
require('config.autocmds').setup()

-- Bootstrap and setup packer
local is_bootstrap = require('config.packer').setup()
if is_bootstrap then
  return -- Exit if bootstrapping
end

-- Load plugin configurations
require('plugins.theme').setup()
require('plugins.telescope').setup()
require('plugins.treesitter').setup()
require('plugins.lsp').setup()
require('plugins.completion').setup()
require('plugins.ui').setup()
require('plugins.windsurf').setup()
require('plugins.claude-code').setup()
require('plugins.git-worktree').setup()

-- vim: ts=2 sts=2 sw=2 et
