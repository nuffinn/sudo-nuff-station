-- Theme configuration
--
-- Light/dark follows the system toggle (Super+D, ~/.config/hypr/toggle-theme.sh).
-- That script writes the mode to ~/.local/state/theme-mode, which is read here at
-- startup, and pushes the change into every running nvim over its RPC socket:
--   nvim --server <sock> --remote-expr "luaeval('require(\"plugins.theme\").apply(_A)', 'light')"
-- `:ThemeToggle`, `:ThemeLight` and `:ThemeDark` switch just this instance.
local M = {}

local STATE_FILE = vim.fn.expand('~/.local/state/theme-mode')

-- Dark: onedark "deep" with the pure-black, neon overrides this config always had.
-- Light: onedark "light" recoloured with Modus Operandi values (black on white,
-- every accent >= 7:1 contrast) to match the kitty light theme.
local styles = {
  dark = {
    style = 'deep',
    colors = {
      bg0 = '#000000',
      grey = '#616161',
      cyan = '#2de8fc',
      fg = '#ffffff',
      purple = '#ff2e5f',
      blue = '#996eff',
      green = '#a0ff52',
    },
  },
  light = {
    style = 'light',
    colors = {
      black = '#000000',
      bg0 = '#ffffff',
      bg1 = '#f2f2f2',
      bg2 = '#e0e0e0',
      bg3 = '#c4c4c4',
      bg_d = '#f0f0f0',
      bg_blue = '#9fc6ff',
      bg_yellow = '#f3d000',
      fg = '#000000',
      purple = '#721045',
      green = '#006800',
      orange = '#884900',
      blue = '#0031a9',
      yellow = '#6f5500',
      cyan = '#005e8b',
      red = '#a60000',
      grey = '#595959',
      light_grey = '#4a4a4a',
      dark_cyan = '#004850',
      dark_red = '#7f0000',
      dark_yellow = '#5f4400',
      dark_purple = '#531ab6',
      diff_add = '#c9ffea',
      diff_delete = '#ffd8e5',
      diff_change = '#e2ecfb',
      diff_text = '#c0cff5',
    },
  },
}

local function read_mode()
  local f = io.open(STATE_FILE, 'r')
  if not f then return 'dark' end
  local mode = vim.trim(f:read('*l') or '')
  f:close()
  return styles[mode] and mode or 'dark'
end

---Switch the whole UI to 'light' or 'dark'. Safe to call any time, including
---over RPC from the toggle script.
function M.apply(mode)
  if not styles[mode] then mode = 'dark' end
  M.mode = mode

  -- Start from onedark's defaults each time; its option merge is a deep
  -- extend, so colour keys from the previous mode would otherwise linger.
  vim.g.onedark_config = nil
  require('onedark').setup(styles[mode])
  vim.o.background = mode
  vim.cmd.colorscheme('onedark')
  return mode
end

function M.setup()
  M.apply(read_mode())

  vim.api.nvim_create_user_command('ThemeLight', function() M.apply('light') end, {})
  vim.api.nvim_create_user_command('ThemeDark', function() M.apply('dark') end, {})
  vim.api.nvim_create_user_command('ThemeToggle', function()
    M.apply(M.mode == 'dark' and 'light' or 'dark')
  end, {})
end

return M
