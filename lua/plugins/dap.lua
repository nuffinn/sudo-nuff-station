local M = {}

function M.setup()
  local dap = require('dap')
  local dapui = require('dapui')

  -- Setup DAP UI
  dapui.setup({
    icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
    mappings = {
      expand = { '<CR>', '<2-LeftMouse>' },
      open = 'o',
      remove = 'd',
      edit = 'e',
      repl = 'r',
      toggle = 't',
    },
    layouts = {
      {
        elements = {
          { id = 'scopes', size = 0.25 },
          'breakpoints',
          'stacks',
          'watches',
        },
        size = 40,
        position = 'left',
      },
      {
        elements = {
          'repl',
          'console',
        },
        size = 0.25,
        position = 'bottom',
      },
    },
    controls = {
      enabled = true,
      element = 'repl',
      icons = {
        pause = '',
        play = '',
        step_into = '',
        step_over = '',
        step_out = '',
        step_back = '',
        run_last = '',
        terminate = '',
      },
    },
    floating = {
      max_height = nil,
      max_width = nil,
      border = 'single',
      mappings = {
        close = { 'q', '<Esc>' },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil,
      max_value_lines = 100,
    },
  })

  -- Setup virtual text
  require('nvim-dap-virtual-text').setup({
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    only_first_definition = true,
    all_references = false,
    virt_text_pos = 'eol',
    all_frames = false,
    virt_lines = false,
    virt_text_win_col = nil,
  })

  -- Setup Go DAP
  require('dap-go').setup({
    delve = {
      path = 'dlv',
      initialize_timeout_sec = 20,
      port = '${port}',
      args = {},
      build_flags = '',
      cwd = nil,
    },
  })

  -- Override configurations to build entire package (fixes Wire and multi-file projects)
  dap.configurations.go = {
    {
      type = 'go',
      name = 'Debug Package',
      request = 'launch',
      program = '${fileDirname}',
    },
    {
      type = 'go',
      name = 'Debug Package (with args)',
      request = 'launch',
      program = '${fileDirname}',
      args = function()
        local args_string = vim.fn.input('Arguments: ')
        return vim.split(args_string, ' ')
      end,
    },
    {
      type = 'go',
      name = 'Debug Test',
      request = 'launch',
      mode = 'test',
      program = '${fileDirname}',
    },
    {
      type = 'go',
      name = 'Attach',
      mode = 'local',
      request = 'attach',
      processId = require('dap.utils').pick_process,
    },
  }

  -- Setup TypeScript/JavaScript DAP adapter manually
  dap.adapters['pwa-node'] = {
    type = 'server',
    host = 'localhost',
    port = '${port}',
    executable = {
      command = 'node',
      args = {
        vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
        '${port}',
      },
    },
  }

  -- TypeScript/JavaScript configurations
  for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
    dap.configurations[language] = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch Server (build & debug)',
        preLaunchTask = 'npm: build',
        program = '${workspaceFolder}/build/index.js',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        outFiles = { '${workspaceFolder}/build/**/*.js' },
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to Process',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        outFiles = { '${workspaceFolder}/build/**/*.js' },
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Debug Current TS File',
        program = '${file}',
        cwd = '${workspaceFolder}',
        runtimeArgs = { '-r', 'ts-node/register' },
        sourceMaps = true,
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Debug Jest Tests',
        runtimeExecutable = 'node',
        runtimeArgs = {
          './node_modules/jest/bin/jest.js',
          '--runInBand',
        },
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Debug npm script',
        runtimeExecutable = 'npm',
        runtimeArgs = function()
          local script = vim.fn.input('Script name: ')
          return { 'run', script }
        end,
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
    }
  end

  -- Auto open/close UI
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end

  -- Keymaps
  vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = 'Debug: Start/Continue' })
  vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = 'Debug: Step Over' })
  vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = 'Debug: Step Into' })
  vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = 'Debug: Step Out' })
  vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
  vim.keymap.set('n', '<leader>B', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end, { desc = 'Debug: Set Conditional Breakpoint' })

  -- Toggle UI
  vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { desc = 'Debug: Toggle UI' })
  vim.keymap.set('n', '<leader>de', function() dapui.eval() end, { desc = 'Debug: Evaluate Expression' })

  -- Go specific debug commands
  vim.keymap.set('n', '<leader>dt', function() require('dap-go').debug_test() end, { desc = 'Debug: Go Test' })
  vim.keymap.set('n', '<leader>dl', function() require('dap-go').debug_last_test() end, { desc = 'Debug: Go Last Test' })

  -- Breakpoint signs
  vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = '', linehl = '', numhl = '' })
  vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = '', linehl = '', numhl = '' })
  vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = '', linehl = '', numhl = '' })
end

return M
