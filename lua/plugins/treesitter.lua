-- Treesitter configuration (nvim-treesitter `main` branch, Neovim 0.12+)
-- The legacy `master` branch is archived and crashes on 0.12; `main` is a full
-- rewrite where highlighting/folding/incremental-selection come from Neovim core
-- and only parser install + textobjects live in the plugin.
local M = {}

-- Parsers to keep installed. Add more anytime with `:TSInstall <lang>`.
local parsers = {
  'c', 'cpp', 'dart', 'go', 'gomod', 'gosum', 'gowork', 'html', 'latex',
  'lua', 'markdown', 'markdown_inline', 'python', 'query', 'rust', 'tsx',
  'typescript', 'vim', 'vimdoc', 'yaml',
}

function M.setup()
  local ok, ts = pcall(require, 'nvim-treesitter')
  -- `main` exposes setup()/install(); `master` does not. If we're still on the
  -- old branch (pre-:PackerSync), bail quietly — this also means the old
  -- crashing `configs.setup` highlighter is never enabled in the meantime.
  if not ok or type(ts.setup) ~= 'function' or type(ts.install) ~= 'function' then
    return
  end

  -- Where parsers/queries get installed (prepended to runtimepath for priority).
  ts.setup { install_dir = vim.fn.stdpath('data') .. '/site' }

  -- ensure_installed equivalent: install any missing parsers (no-op otherwise).
  local installed = require('nvim-treesitter.config').get_installed()
  local missing = vim.tbl_filter(function(lang)
    return not vim.tbl_contains(installed, lang)
  end, parsers)
  if #missing > 0 then
    ts.install(missing)
  end

  -- Highlighting (core) + experimental treesitter indent, enabled per-buffer.
  -- Folding is configured globally in config/options.lua via vim.treesitter.foldexpr().
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('nvim_treesitter_start', { clear = true }),
    callback = function(ev)
      -- vim.treesitter.start() infers the language from the filetype and errors
      -- when no parser is installed -> pcall keeps it silent for unsupported fts.
      if not pcall(vim.treesitter.start, ev.buf) then
        return
      end
      -- Match the old config: treesitter indent everywhere except python.
      if vim.bo[ev.buf].filetype ~= 'python' then
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })

  -- Incremental selection is now built into Neovim 0.12 (visual mode):
  --   an / in  -> grow / shrink to parent / child node
  --   ]n / [n  -> next / previous sibling node
  -- (replaces the old <c-space> incremental_selection module)

  -- Textobjects (nvim-treesitter-textobjects `main` branch: setup + manual maps)
  local to_ok, textobjects = pcall(require, 'nvim-treesitter-textobjects')
  if not to_ok then
    return
  end
  textobjects.setup {
    select = {
      lookahead = true,
      selection_modes = {
        ['@parameter.outer'] = 'v',
        ['@function.outer'] = 'V',
        ['@class.outer'] = 'V',
      },
    },
    move = { set_jumps = true },
  }

  local select = require('nvim-treesitter-textobjects.select').select_textobject
  local move = require('nvim-treesitter-textobjects.move')
  local swap = require('nvim-treesitter-textobjects.swap')

  local function sel(obj)
    return function() select(obj, 'textobjects') end
  end

  -- select
  vim.keymap.set({ 'x', 'o' }, 'aa', sel('@parameter.outer'), { desc = 'a parameter' })
  vim.keymap.set({ 'x', 'o' }, 'ia', sel('@parameter.inner'), { desc = 'inner parameter' })
  vim.keymap.set({ 'x', 'o' }, 'af', sel('@function.outer'), { desc = 'a function' })
  vim.keymap.set({ 'x', 'o' }, 'if', sel('@function.inner'), { desc = 'inner function' })
  vim.keymap.set({ 'x', 'o' }, 'ac', sel('@class.outer'), { desc = 'a class' })
  vim.keymap.set({ 'x', 'o' }, 'ic', sel('@class.inner'), { desc = 'inner class' })

  -- move
  local nxo = { 'n', 'x', 'o' }
  vim.keymap.set(nxo, ']]', function() move.goto_next_start('@function.outer', 'textobjects') end, { desc = 'Next function start' })
  vim.keymap.set(nxo, ']m', function() move.goto_next_start('@class.outer', 'textobjects') end, { desc = 'Next class start' })
  vim.keymap.set(nxo, '][', function() move.goto_next_end('@function.outer', 'textobjects') end, { desc = 'Next function end' })
  vim.keymap.set(nxo, ']M', function() move.goto_next_end('@class.outer', 'textobjects') end, { desc = 'Next class end' })
  vim.keymap.set(nxo, '[[', function() move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'Prev function start' })
  vim.keymap.set(nxo, '[m', function() move.goto_previous_start('@class.outer', 'textobjects') end, { desc = 'Prev class start' })
  vim.keymap.set(nxo, '[]', function() move.goto_previous_end('@function.outer', 'textobjects') end, { desc = 'Prev function end' })
  vim.keymap.set(nxo, '[M', function() move.goto_previous_end('@class.outer', 'textobjects') end, { desc = 'Prev class end' })

  -- swap
  vim.keymap.set('n', '<leader>pa', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap parameter with next' })
  vim.keymap.set('n', '<leader>pA', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap parameter with previous' })
end

return M
