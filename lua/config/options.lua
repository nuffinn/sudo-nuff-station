-- Core Neovim options and settings
local M = {}

function M.setup()
  -- Leader keys
  vim.keymap.set("", "<Space>", "<Nop>", { silent = true })
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- General options
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.cursorline = true
  vim.opt.hlsearch = false
  vim.opt.shiftwidth = 3
  vim.opt.mouse = 'a'
  vim.opt.breakindent = true
  vim.opt.undofile = true
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.termguicolors = true
  vim.opt.signcolumn = 'yes'
  vim.opt.completeopt = 'menuone,noselect'
  vim.opt.autoread = true

  -- Terminal and tmux compatibility
  vim.opt.ttimeout = true
  vim.opt.ttimeoutlen = 50

  -- Better LSP experience
  vim.opt.updatetime = 100
  vim.opt.redrawtime = 10000

  -- Built-in folding with treesitter
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.opt.foldenable = true
  vim.opt.foldlevel = 99  -- Start with most folds open
end

return M
