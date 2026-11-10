-- UI and statusline configuration
local M = {}

function M.setup()
  -- Setup nvim-navic
  require('nvim-navic').setup {
    icons = {
      File          = ' ',
      Module        = ' ',
      Namespace     = ' ',
      Package       = ' ',
      Class         = ' ',
      Method        = ' ',
      Property      = ' ',
      Field         = ' ',
      Constructor   = ' ',
      Enum          = ' ',
      Interface     = ' ',
      Function      = ' ',
      Variable      = ' ',
      Constant      = ' ',
      String        = ' ',
      Number        = ' ',
      Boolean       = ' ',
      Array         = ' ',
      Object        = ' ',
      Key           = ' ',
      Null          = ' ',
      EnumMember    = ' ',
      Struct        = ' ',
      Event         = ' ',
      Operator      = ' ',
      TypeParameter = ' ',
    },
  }

  -- Setup lualine with navic integration
  local navic = require 'nvim-navic'

  require('lualine').setup {
    options = {
      icons_enabled = false,
      theme = 'onedark',
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_c = {
        {
          'filename',
          file_status = true,
          path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
          color = 'CustomFileName',
        },
        {
          function() return navic.get_location() end,
          cond = function() return navic.is_available() end,
          color = 'CustomGpsOutput',
        },
      },
    },
  }
  
  -- Setup gitsigns
  require('gitsigns').setup {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      -- Set by the lazygit `E` command (commit files view) for files deleted in
      -- that commit: the buffer shows the previous version, nothing to diff
      if vim.b[bufnr].gitsigns_skip then
        return false
      end

      local gs = require('gitsigns')

      -- Jump to next git change. target = 'all' also visits staged hunks, which is
      -- how gitsigns marks a commit's changes in a buffer of a file at that commit
      -- (`:Gedit <hash>:<path>`, opened by the lazygit `E` command)
      vim.keymap.set('n', 'gn', function()
        gs.nav_hunk('next', { target = 'all' })
      end, { buffer = bufnr, desc = '[N]ext [G]it change' })

      -- Preview hunk inline
      vim.keymap.set('n', 'gpi', gs.preview_hunk_inline, { buffer = bufnr, desc = '[G]it [P]review hunk [I]nline' })
    end,
  }
  
  -- Setup DAP UI
  require('dapui').setup()
  
  -- Setup git blame
  require('gitblame').setup {
    enabled = false,
  }
end

return M
