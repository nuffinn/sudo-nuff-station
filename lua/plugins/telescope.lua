-- Telescope configuration
local M = {}

function M.setup()
  -- Configure Telescope
  require('telescope').setup {
    defaults = {
      prompt_prefix = '🔍 ',
      selection_caret = '➤ ',
      mappings = {
        i = {
          ['<C-u>'] = false,
          ['<C-d>'] = false,
          -- Clear any conflicting mappings
          ['<A-a>'] = false,
          ['<A-A>'] = false,
        },
        n = {
          -- Disable problematic normal mode mappings
          ['A'] = false,
          ['a'] = false,
          -- Add 'o' to open files (same as Enter)
          ['o'] = require('telescope.actions').select_default,
        },
      },
    },
    pickers = {
      lsp_references = {
        show_line = false,
        initial_mode = 'normal',
        layout_config = {
          preview_width = 0.6,
        },
      },
      lsp_definitions = {
        initial_mode = 'normal',
        layout_config = {
          preview_width = 0.6,
        },
      },
      find_files = {
        hidden = true,
      },
    },
  }

  -- Enable telescope fzf native, if installed
  pcall(require('telescope').load_extension, 'fzf')

  -- Telescope keymaps
  local builtin = require('telescope.builtin')

  vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
  vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', function()
    builtin.diagnostics({ severity = vim.diagnostic.severity.ERROR })
  end, { desc = '[S]earch [D]iagnostics (errors only)' })
end

return M
