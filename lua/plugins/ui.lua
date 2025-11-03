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
  }
  
  -- Setup DAP UI
  require('dapui').setup()
  
  -- Setup git blame
  require('gitblame').setup {
    enabled = false,
  }
end

return M
