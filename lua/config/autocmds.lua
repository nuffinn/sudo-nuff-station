-- Auto commands and highlights
local M = {}

function M.setup()
  -- Highlight on yank
  local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
  })
  
  -- Custom highlights
  vim.cmd [[
    highlight CustomFileName guifg=#abcdef guibg=#590055 gui=bold
    highlight CustomGpsOutput guifg=#00186e guibg=#e36fa1 gui=italic
    highlight CursorLineNr guifg=#ffaa00 gui=bold
  ]]

  -- TypeScript custom color theme for better readability
  local ts_highlight_group = vim.api.nvim_create_augroup('TypeScriptHighlights', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    group = ts_highlight_group,
    callback = function()
      -- Keywords (const, let, function, return, if, else, etc.)
      vim.api.nvim_set_hl(0, '@keyword.typescript', { fg = '#ff79c6', bold = true })
      vim.api.nvim_set_hl(0, '@keyword.typescriptreact', { fg = '#ff79c6', bold = true })
      vim.api.nvim_set_hl(0, '@keyword.return.typescript', { fg = '#ff5555', bold = true })
      vim.api.nvim_set_hl(0, '@keyword.return.typescriptreact', { fg = '#ff5555', bold = true })
      vim.api.nvim_set_hl(0, '@keyword.function.typescript', { fg = '#ff79c6', bold = true })
      vim.api.nvim_set_hl(0, '@keyword.function.typescriptreact', { fg = '#ff79c6', bold = true })
      vim.api.nvim_set_hl(0, '@keyword.export.typescript', { fg = '#ffb86c', bold = true })
      vim.api.nvim_set_hl(0, '@keyword.import.typescript', { fg = '#ffb86c', bold = true })

      -- Types and interfaces - bright cyan for visibility
      vim.api.nvim_set_hl(0, '@type.typescript', { fg = '#8be9fd', bold = true })
      vim.api.nvim_set_hl(0, '@type.typescriptreact', { fg = '#8be9fd', bold = true })
      vim.api.nvim_set_hl(0, '@type.builtin.typescript', { fg = '#8be9fd' })
      vim.api.nvim_set_hl(0, '@type.builtin.typescriptreact', { fg = '#8be9fd' })

      -- Function names - bright green
      vim.api.nvim_set_hl(0, '@function.typescript', { fg = '#50fa7b' })
      vim.api.nvim_set_hl(0, '@function.typescriptreact', { fg = '#50fa7b' })
      vim.api.nvim_set_hl(0, '@function.call.typescript', { fg = '#50fa7b' })
      vim.api.nvim_set_hl(0, '@function.call.typescriptreact', { fg = '#50fa7b' })
      vim.api.nvim_set_hl(0, '@function.method.typescript', { fg = '#50fa7b' })
      vim.api.nvim_set_hl(0, '@function.method.typescriptreact', { fg = '#50fa7b' })

      -- Variables and parameters - soft white/cream
      vim.api.nvim_set_hl(0, '@variable.typescript', { fg = '#f8f8f2' })
      vim.api.nvim_set_hl(0, '@variable.typescriptreact', { fg = '#f8f8f2' })
      vim.api.nvim_set_hl(0, '@variable.parameter.typescript', { fg = '#ffb86c', italic = true })
      vim.api.nvim_set_hl(0, '@variable.parameter.typescriptreact', { fg = '#ffb86c', italic = true })
      vim.api.nvim_set_hl(0, '@variable.member.typescript', { fg = '#bd93f9' })
      vim.api.nvim_set_hl(0, '@variable.member.typescriptreact', { fg = '#bd93f9' })

      -- Strings - warm yellow
      vim.api.nvim_set_hl(0, '@string.typescript', { fg = '#f1fa8c' })
      vim.api.nvim_set_hl(0, '@string.typescriptreact', { fg = '#f1fa8c' })

      -- Numbers - bright purple
      vim.api.nvim_set_hl(0, '@number.typescript', { fg = '#bd93f9' })
      vim.api.nvim_set_hl(0, '@number.typescriptreact', { fg = '#bd93f9' })

      -- Operators - bright white
      vim.api.nvim_set_hl(0, '@operator.typescript', { fg = '#ffffff' })
      vim.api.nvim_set_hl(0, '@operator.typescriptreact', { fg = '#ffffff' })

      -- Comments - muted but readable gray
      vim.api.nvim_set_hl(0, '@comment.typescript', { fg = '#6272a4', italic = true })
      vim.api.nvim_set_hl(0, '@comment.typescriptreact', { fg = '#6272a4', italic = true })

      -- Punctuation - subtle gray
      vim.api.nvim_set_hl(0, '@punctuation.bracket.typescript', { fg = '#aaaaaa' })
      vim.api.nvim_set_hl(0, '@punctuation.bracket.typescriptreact', { fg = '#aaaaaa' })
      vim.api.nvim_set_hl(0, '@punctuation.delimiter.typescript', { fg = '#aaaaaa' })
      vim.api.nvim_set_hl(0, '@punctuation.delimiter.typescriptreact', { fg = '#aaaaaa' })

      -- Constants and booleans
      vim.api.nvim_set_hl(0, '@constant.typescript', { fg = '#bd93f9' })
      vim.api.nvim_set_hl(0, '@constant.typescriptreact', { fg = '#bd93f9' })
      vim.api.nvim_set_hl(0, '@boolean.typescript', { fg = '#bd93f9', bold = true })
      vim.api.nvim_set_hl(0, '@boolean.typescriptreact', { fg = '#bd93f9', bold = true })

      -- Properties/keys in objects
      vim.api.nvim_set_hl(0, '@property.typescript', { fg = '#66d9ef' })
      vim.api.nvim_set_hl(0, '@property.typescriptreact', { fg = '#66d9ef' })

      -- JSX/TSX specific (React components)
      vim.api.nvim_set_hl(0, '@tag.tsx', { fg = '#ff79c6' })
      vim.api.nvim_set_hl(0, '@tag.attribute.tsx', { fg = '#50fa7b', italic = true })
      vim.api.nvim_set_hl(0, '@tag.delimiter.tsx', { fg = '#aaaaaa' })

      -- Constructor
      vim.api.nvim_set_hl(0, '@constructor.typescript', { fg = '#8be9fd', bold = true })
      vim.api.nvim_set_hl(0, '@constructor.typescriptreact', { fg = '#8be9fd', bold = true })
    end,
  })
  
  -- Auto-enable git blame in git repositories
  local gitblame_group = vim.api.nvim_create_augroup('GitBlameAuto', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      local git_dir = vim.fn.finddir('.git', vim.fn.expand('%:p:h') .. ';')
      if git_dir ~= '' then
        vim.cmd('GitBlameEnable')
      end
    end,
    group = gitblame_group,
    pattern = '*',
  })
  
  -- Packer auto-reload
  local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePost', {
    command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
    group = packer_group,
    pattern = vim.fn.expand '$MYVIMRC',
  })
end

return M
