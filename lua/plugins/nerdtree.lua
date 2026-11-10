-- NERDTree tweaks
local M = {}

-- Colour for Go test files in the tree. The syntax match that feeds this group
-- lives in after/syntax/nerdtree.vim (it has to be defined after NERDTree's own
-- syntax file, which is re-sourced -- and preceded by `syn clear` -- every time
-- a tree buffer is created).
local TEST_FILE_FG = '#5c6370'

function M.setup()
  local function set_highlight()
    vim.api.nvim_set_hl(0, 'NERDTreeGoTestFile', { fg = TEST_FILE_FG })
  end

  -- Any :colorscheme clears user highlight groups, so re-apply after one.
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('NerdTreeGoTestFiles', { clear = true }),
    callback = set_highlight,
  })

  set_highlight()
end

return M
