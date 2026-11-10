-- Keymapping configuration
local M = {}

function M.setup()
  -- Basic keymaps
  vim.keymap.set("n", "<leader>w", ":write<CR>", { silent = true, desc = "Save file" })

  -- Remap for dealing with word wrap
  vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

  -- Diagnostic keymaps
  -- [d / ]d are built-in defaults in Neovim 0.11+ (backed by vim.diagnostic.jump
  -- with count support, e.g. 3]d), so we no longer remap them via the deprecated
  -- vim.diagnostic.goto_prev/goto_next (scheduled for removal in 0.13).
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open diagnostic float" })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Set diagnostic loclist" })

  -- Go formatting
  vim.api.nvim_set_keymap('n', '<leader>fm', ':GoFmt<CR>', { noremap = true, silent = true, desc = "Format Go file" })
  -- NERDTree
  vim.api.nvim_set_keymap('n', '<leader>tf', ':NERDTreeFind<CR>',
    { noremap = true, silent = true, desc = "Find in NERDTree" })

  vim.api.nvim_set_keymap('n', '<leader>tr', ':NERDTreeRefreshRoot<CR>',
    { noremap = true, silent = true, desc = "NERDTree Refresh Root" })

  -- LSP debug keybindings
  vim.keymap.set('n', '<leader>li', ':LspInfo<CR>', { desc = 'LSP Info' })
  vim.keymap.set('n', '<leader>lr', ':LspRestart<CR>', { desc = 'LSP Restart' })

  -- Toggle format on save
  vim.keymap.set('n', '<leader>ff', function()
    local conform = require('conform')
    local current_config = conform.formatters_by_ft

    if vim.g.format_on_save_enabled == nil then
      vim.g.format_on_save_enabled = true -- Initially enabled
    end

    if vim.g.format_on_save_enabled then
      -- Disable format on save
      conform.setup({
        formatters_by_ft = current_config,
        format_on_save = nil
      })
      vim.g.format_on_save_enabled = false
      print("Format on save disabled")
    else
      -- Enable format on save
      conform.setup({
        formatters_by_ft = current_config,
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 3000,
        }
      })
      vim.g.format_on_save_enabled = true
      print("Format on save enabled")
    end
  end, { desc = 'Toggle format on save' })

  -- Git Worktree keymaps
  vim.keymap.set('n', '<leader>gw', function()
    require('plugins.git-worktree').git_worktrees_with_vsplit()
  end, { desc = 'Git worktrees (list/switch/delete/vsplit)' })

  vim.keymap.set('n', '<leader>gc', function()
    require('telescope').extensions.git_worktree.create_git_worktree()
  end, { desc = 'Git worktree create' })

  -- Copy to linux clipboard
  vim.keymap.set('v', '<C-y>', '"+y', { desc = 'Copy to linux clipboard' })

  -- Git blame
  vim.keymap.set('n', '<S-j>', function()
    require('gitsigns').blame_line({ full = true })
  end, { desc = 'Show git blame for current line' })

  -- Toggle maximize/unmaximize current window
  vim.keymap.set('n', '<leader>m', function()
    if vim.t.maximized then
      -- Restore the saved window layout
      if vim.t.window_layout then
        vim.cmd(vim.t.window_layout)
      end
      vim.t.maximized = false
    else
      -- Save current window layout before maximizing
      vim.t.window_layout = vim.fn.winrestcmd()
      vim.cmd('wincmd |')
      vim.cmd('wincmd _')
      vim.t.maximized = true
    end
  end, { desc = 'Toggle maximize current window' })
end

return M
