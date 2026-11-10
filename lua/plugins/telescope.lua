-- Telescope configuration
local M = {}

-- Go test files (anything ending in `test.go`) are skipped by the file, grep and
-- reference pickers. This is applied per-picker rather than as a global
-- `file_ignore_patterns` so that go-to-definition (gd / gy) always works, even
-- when the only definition of a symbol lives in a test file.
-- Toggle with :TelescopeGoTests or <leader>st.
local hide_go_tests = true
local GO_TEST_IGNORE = { 'test%.go$' }      -- lua pattern, matched against the path
local GO_TEST_RG_ARGS = { '--glob', '!*test.go' } -- ripgrep never opens them

local function in_go_test_buffer()
  return vim.endswith(vim.api.nvim_buf_get_name(0), 'test.go')
end

local function file_opts(opts)
  opts = opts or {}
  if hide_go_tests then
    opts.file_ignore_patterns = GO_TEST_IGNORE
  end
  return opts
end

local function grep_opts(opts)
  opts = file_opts(opts)
  if hide_go_tests then
    opts.additional_args = GO_TEST_RG_ARGS
  end
  return opts
end

-- Used by the LSP pickers in lua/plugins/lsp.lua (gr / gI / gW) so they honour
-- the same toggle. While editing a test file the filter steps aside: there you
-- do want to see the other test files.
function M.lsp_opts(opts)
  opts = opts or {}
  if hide_go_tests and not in_go_test_buffer() then
    opts.file_ignore_patterns = GO_TEST_IGNORE
  end
  return opts
end

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

  vim.keymap.set('n', '<leader>sf', function()
    builtin.find_files(file_opts())
  end, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', function()
    builtin.grep_string(grep_opts())
  end, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', function()
    builtin.live_grep(grep_opts())
  end, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', function()
    builtin.diagnostics({ severity = vim.diagnostic.severity.ERROR })
  end, { desc = '[S]earch [D]iagnostics (errors only)' })

  -- Bring Go test files back into the file/grep pickers when you do want them.
  local function toggle_go_tests()
    hide_go_tests = not hide_go_tests
    vim.notify('Go test files ' .. (hide_go_tests and 'hidden from' or 'included in') ..
      ' Telescope file/grep search')
  end

  vim.api.nvim_create_user_command('TelescopeGoTests', toggle_go_tests,
    { desc = 'Toggle *test.go files in Telescope file/grep search' })
  vim.keymap.set('n', '<leader>st', toggle_go_tests, { desc = '[S]earch: toggle Go [t]est files' })
end

return M
