-- Log file viewing: highlighting (log-highlight.nvim), follow mode, level
-- navigation, focus folds, JSON pretty-print and a big-file guard
local M = {}

-- Files above this size open with syntax highlighting off
local BIG_FILE = 50 * 1024 * 1024

-- Level patterns for ]e/[e and ]w/[w (very magic, case-insensitive)
local ERROR_PAT = [[\v\c<(fatal|panic|dpanic|critical|error|err|exception|traceback)>]]
local WARN_PAT = [[\v\c<(warn|warning)>]]

-- Pretty-prints Python literals (dict reprs, b'...' JSON payloads) when jq fails
local PY_PRETTY = [[
import ast, json, sys
line = sys.stdin.read()

def parse(text):
    try:
        v = ast.literal_eval(text)
    except Exception:
        return None
    if isinstance(v, (bytes, str)):
        try:
            v = json.loads(v)
        except Exception:
            return None
    return v if isinstance(v, (dict, list)) else None

cands = []
s, e = line.find('{'), line.rfind('}')
if 0 <= s < e:
    cands.append(line[s:e + 1])
for prefix in ("b'", 'b"'):
    s = line.find(prefix)
    if s >= 0:
        cands.append(line[s:line.rfind(prefix[1]) + 1])
for c in cands:
    v = parse(c)
    if v is not None:
        print(json.dumps(v, indent=2, ensure_ascii=False, default=str))
        sys.exit(0)
sys.exit(1)
]]

-- buf -> uv fs_poll handle for buffers in follow mode
local followers = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'log' })
end

local function jump(pat, backward)
  if vim.fn.search(pat, backward and 'b' or '') == 0 then
    notify('No match for ' .. (pat == ERROR_PAT and 'errors' or 'warnings'))
  end
end

-- Reload the buffer from disk, keeping windows that sat on the last line pinned
-- to the (new) last line, like `tail -f`
local function reload(buf)
  local pinned = {}
  local last = vim.api.nvim_buf_line_count(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if vim.api.nvim_win_get_cursor(win)[1] == last then
      table.insert(pinned, win)
    end
  end
  -- silent: skip the "Buffer reloaded" message on every poll
  vim.cmd('silent checktime ' .. buf)
  last = vim.api.nvim_buf_line_count(buf)
  for _, win in ipairs(pinned) do
    vim.api.nvim_win_set_cursor(win, { last, 0 })
  end
end

local function follow_stop(buf)
  local poll = followers[buf]
  if poll then
    poll:stop()
    poll:close()
    followers[buf] = nil
  end
end

local function follow_toggle()
  local buf = vim.api.nvim_get_current_buf()
  if followers[buf] then
    follow_stop(buf)
    notify('Follow off')
    return
  end

  local path = vim.api.nvim_buf_get_name(buf)
  if path == '' or vim.fn.filereadable(path) == 0 then
    notify('Follow needs a file on disk', vim.log.levels.WARN)
    return
  end

  -- fs_poll compares stat results, so it survives log rotation (rename +
  -- recreate, or copytruncate) where an inotify watch would go stale
  local poll = assert(vim.uv.new_fs_poll())
  poll:start(path, 500, vim.schedule_wrap(function(err)
    if not vim.api.nvim_buf_is_valid(buf) then
      follow_stop(buf)
    elseif not err then
      reload(buf)
    end
  end))
  followers[buf] = poll

  vim.api.nvim_create_autocmd({ 'BufUnload', 'BufWipeout' }, {
    buffer = buf,
    once = true,
    callback = function()
      follow_stop(buf)
    end,
  })

  vim.cmd('normal! G')
  notify('Follow on')
end

-- Fold away every line not matching the last search pattern (snapshot taken
-- when focus turns on); toggling again restores the window's fold settings
local function focus_toggle()
  local saved = vim.w.log_focus
  if saved then
    for name, value in pairs(saved) do
      vim.wo[name] = value
    end
    vim.w.log_focus = nil
    vim.w.log_focus_pat = nil
    return
  end

  local pat = vim.fn.getreg('/')
  if pat == '' then
    notify('Search for something first (/pattern), then focus on it', vim.log.levels.WARN)
    return
  end

  local names = { 'foldmethod', 'foldexpr', 'foldlevel', 'foldenable', 'foldminlines', 'foldtext' }
  saved = {}
  for _, name in ipairs(names) do
    saved[name] = vim.wo[name]
  end
  vim.w.log_focus = saved
  vim.w.log_focus_pat = pat

  vim.wo.foldexpr = 'getline(v:lnum) =~ w:log_focus_pat ? 0 : 1'
  vim.wo.foldtext = "'  ··· ' . (v:foldend - v:foldstart + 1) . ' lines hidden'"
  vim.wo.foldmethod = 'expr'
  vim.wo.foldminlines = 0
  vim.wo.foldlevel = 0
  vim.wo.foldenable = true
end

local function search_to_loclist()
  if vim.fn.getreg('/') == '' then
    notify('Search for something first (/pattern)', vim.log.levels.WARN)
    return
  end
  -- An empty :lvimgrep pattern reuses the last search pattern
  if pcall(vim.cmd, 'lvimgrep //j %') then
    vim.cmd.lopen()
  else
    notify('No matches for /' .. vim.fn.getreg('/'))
  end
end

-- Pretty-print the JSON (or Python literal) on the cursor line in a float.
-- Press K again to enter the float; it closes when the cursor moves.
local function pretty_line()
  local line = vim.api.nvim_get_current_line()
  local out

  local s, e = line:find('{', 1, true), line:match('.*()}')
  for _, text in ipairs({ line, s and e and line:sub(s, e) or nil }) do
    local res = vim.system({ 'jq', '.' }, { stdin = text, text = true }):wait()
    if res.code == 0 and res.stdout ~= '' then
      out = res.stdout
      break
    end
  end

  if not out and vim.fn.executable('python3') == 1 then
    local res = vim.system({ 'python3', '-I', '-c', PY_PRETTY }, { stdin = line, text = true }):wait()
    if res.code == 0 then
      out = res.stdout
    end
  end

  if not out then
    notify('No JSON or Python literal on this line')
    return
  end

  vim.lsp.util.open_floating_preview(vim.split(out, '\n', { trimempty = true }), 'json', {
    border = 'rounded',
    focus_id = 'log_pretty',
    max_width = math.floor(vim.o.columns * 0.8),
    max_height = math.floor(vim.o.lines * 0.7),
  })
end

local function on_log_buffer(buf)
  vim.bo[buf].readonly = true
  vim.bo[buf].swapfile = false
  -- Follow-mode reloads would otherwise pile up undo history
  vim.bo[buf].undolevels = -1

  vim.opt_local.wrap = false
  vim.opt_local.linebreak = true
  vim.opt_local.spell = false
  vim.opt_local.cursorline = true

  -- FileType can fire twice per read (the plugin's ftdetect and
  -- vim.filetype.add both set it), so only notify once
  if vim.b[buf].bigfile then
    vim.bo[buf].syntax = 'OFF'
    if not vim.b[buf].bigfile_notified then
      vim.b[buf].bigfile_notified = true
      notify('Large file: syntax highlighting off')
    end
  end

  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
  end
  map(']e', function() jump(ERROR_PAT) end, 'Log: next error')
  map('[e', function() jump(ERROR_PAT, true) end, 'Log: previous error')
  map(']w', function() jump(WARN_PAT) end, 'Log: next warning')
  map('[w', function() jump(WARN_PAT, true) end, 'Log: previous warning')
  -- <leader>L prefix: maplocalleader is also <Space>, and <leader>f/q/w are taken
  map('<leader>Lf', focus_toggle, '[L]og: [F]ocus on last search (fold the rest)')
  map('<leader>Lq', search_to_loclist, '[L]og: last search to location list')
  map('<leader>Lw', function() vim.wo.wrap = not vim.wo.wrap end, '[L]og: toggle [W]rap')
  map('<leader>LF', follow_toggle, '[L]og: toggle [F]ollow (tail -f)')
  map('K', pretty_line, 'Log: pretty-print JSON on line')
end

function M.setup()
  local ok, log_highlight = pcall(require, 'log-highlight')
  if ok then
    log_highlight.setup {
      -- Rotated logs: app.log.1, app.log.2, ...
      pattern = { '.*%.log%.%d+' },
      keyword = {
        error = { 'panic', 'Panic', 'PANIC', 'Traceback' },
      },
    }
  end

  local group = vim.api.nvim_create_augroup('LogViewing', { clear = true })

  vim.api.nvim_create_autocmd('BufReadPre', {
    group = group,
    callback = function(ev)
      if vim.fn.getfsize(ev.match) > BIG_FILE then
        vim.b[ev.buf].bigfile = true
        vim.bo[ev.buf].swapfile = false
        vim.bo[ev.buf].undolevels = -1
      end
    end,
    desc = 'Skip swap and undo for very large files',
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'log',
    callback = function(ev)
      on_log_buffer(ev.buf)
    end,
  })

  vim.api.nvim_create_user_command('LogFollow', follow_toggle, { desc = 'Toggle tail -f style follow for this buffer' })
end

return M
