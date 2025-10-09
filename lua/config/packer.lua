-- Packer package manager setup
local M = {}

function M.setup()
  local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
  local is_bootstrap = false

  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
    vim.cmd [[packadd packer.nvim]]
  end

  require('packer').startup(function(use)
    -- Package manager
    use 'wbthomason/packer.nvim'

    -- Git and version control
    use 'f-person/git-blame.nvim'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-rhubarb'
    use 'lewis6991/gitsigns.nvim'
    use {
      'ThePrimeagen/git-worktree.nvim',
      requires = 'nvim-telescope/telescope.nvim',
    }

    -- Go development and formatting
    use {
      'stevearc/conform.nvim',
      config = function()
        require('conform').setup({
          formatters_by_ft = {
            go = { 'goimports', 'gofumpt' },
          },
          format_on_save = {
            lsp_fallback = true,
            timeout_ms = 3000,
          },
        })
      end
    }

    -- AI assistance
    use 'zbirenbaum/copilot.lua'
    use 'zbirenbaum/copilot-cmp'
    use {
      'Exafunction/codeium.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'hrsh7th/nvim-cmp'
      }
    }

    -- File explorer
    use 'preservim/nerdtree'

    -- Navigation and status
    use {
      'SmiteshP/nvim-gps',
      requires = 'nvim-treesitter/nvim-treesitter',
    }
    use 'nvim-lualine/lualine.nvim'

    -- Debugging
    use { 'rcarriga/nvim-dap-ui', requires = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } }
    use 'mfussenegger/nvim-dap'

    -- LSP Configuration & Plugins
    use {
      'neovim/nvim-lspconfig',
      requires = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'j-hui/fidget.nvim',
        'folke/neodev.nvim',
      },
    }

    -- Custom plugins
    use { 'augmentcode/augment.vim' }

    -- Claude Code integration for real-time file watching
    use {
      'greggh/claude-code.nvim',
      requires = 'nvim-lua/plenary.nvim',
    }

    -- Autocompletion
    use {
      'hrsh7th/nvim-cmp',
      requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
    }

    -- Treesitter
    use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
        pcall(require('nvim-treesitter.install').update { with_sync = true })
      end,
    }
    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
    }

    -- Theme
    use {
      'navarasu/onedark.nvim',
      config = function()
        require('onedark').setup {
          style = 'deep',
        }
        require('onedark').load()
      end
    }

    -- Utilities
    use 'numToStr/Comment.nvim'
    use 'tpope/vim-sleuth'

    -- Fuzzy Finder
    use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

    if is_bootstrap then
      require('packer').sync()
    end
  end)

  -- Bootstrap check
  if is_bootstrap then
    print '=================================='
    print '    Plugins are being installed'
    print '    Wait until Packer completes,'
    print '       then restart nvim'
    print '=================================='
    return true
  end

  return false
end

return M
