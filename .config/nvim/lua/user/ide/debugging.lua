-- IDE Mode Debugging Configuration
-- 2025.01.08 - nvim-dap setup for Python, JavaScript/TypeScript debugging
-- Comprehensive debugging support for your development stack

local M = {}

-- Setup Python debugging
function M.setup_python_debugging()
  local dap_python = require("dap-python")
  
  -- Try to find Python executable automatically
  local python_path = vim.fn.exepath("python3") or vim.fn.exepath("python")
  if python_path == "" then
    python_path = "/usr/bin/python3"
  end
  
  dap_python.setup(python_path)
  
  -- Python-specific configurations
  table.insert(require("dap").configurations.python, {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      -- Check for virtual environment
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
        return cwd .. "/venv/bin/python"
      elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
        return cwd .. "/.venv/bin/python"
      else
        return python_path
      end
    end,
  })

  -- Django debugging configuration
  table.insert(require("dap").configurations.python, {
    type = "python",
    request = "launch",
    name = "Django",
    program = "${workspaceFolder}/manage.py",
    args = { "runserver" },
    django = true,
    console = "integratedTerminal",
  })

  -- Flask debugging configuration
  table.insert(require("dap").configurations.python, {
    type = "python",
    request = "launch",
    name = "Flask",
    module = "flask",
    env = {
      FLASK_APP = "app.py",
      FLASK_ENV = "development",
    },
    args = { "run" },
    jinja = true,
    console = "integratedTerminal",
  })

  -- pytest debugging
  table.insert(require("dap").configurations.python, {
    type = "python",
    request = "launch",
    name = "pytest",
    module = "pytest",
    args = { "${file}" },
    console = "integratedTerminal",
  })
end

-- Setup JavaScript/TypeScript debugging
function M.setup_js_debugging()
  local dap = require("dap")
  
  -- Node.js debugging
  dap.adapters.node2 = {
    type = "executable",
    command = "node",
    args = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
  }

  -- Chrome debugging
  dap.adapters.chrome = {
    type = "executable",
    command = "node",
    args = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js" },
  }

  -- JavaScript configurations
  dap.configurations.javascript = {
    {
      name = "Launch",
      type = "node2",
      request = "launch",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
    {
      name = "Attach to process",
      type = "node2",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
    {
      name = "Debug with Chrome",
      type = "chrome",
      request = "attach",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      port = 9222,
      webRoot = "${workspaceFolder}",
    },
  }

  -- TypeScript configurations (same as JavaScript)
  dap.configurations.typescript = dap.configurations.javascript

  -- React/Next.js debugging
  table.insert(dap.configurations.javascript, {
    name = "Next.js: debug server-side",
    type = "node2",
    request = "launch",
    cwd = "${workspaceFolder}",
    runtimeArgs = { "--inspect" },
    runtimeExecutable = "npm",
    args = { "run", "dev" },
    sourceMaps = true,
    protocol = "inspector",
    console = "integratedTerminal",
  })

  table.insert(dap.configurations.javascript, {
    name = "Next.js: debug client-side",
    type = "chrome",
    request = "launch",
    url = "http://localhost:3000",
    webRoot = "${workspaceFolder}",
    sourceMaps = true,
    protocol = "inspector",
  })
end

-- Setup DAP UI with enhanced configuration
function M.setup_dap_ui()
  local dapui = require("dapui")
  
  dapui.setup({
    icons = { expanded = "", collapsed = "", current_frame = "" },
    mappings = {
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    element_mappings = {},
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    force_buffers = true,
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40,
        position = "left",
      },
      {
        elements = {
          "repl",
          "console",
        },
        size = 0.25,
        position = "bottom",
      },
    },
    controls = {
      enabled = true,
      element = "repl",
      icons = {
        pause = "",
        play = "",
        step_into = "",
        step_over = "",
        step_out = "",
        step_back = "",
        run_last = "",
        terminate = "",
      },
    },
    floating = {
      max_height = nil,
      max_width = nil,
      border = "single",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil,
      max_value_lines = 100,
    },
  })

  -- Auto-open DAP UI when debugging starts
  local dap = require("dap")
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

-- Setup virtual text for debugging
function M.setup_virtual_text()
  require("nvim-dap-virtual-text").setup({
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    only_first_definition = true,
    all_references = false,
    filter_references_pattern = "<module",
    virt_text_pos = "eol",
    all_frames = false,
    virt_lines = false,
    virt_text_win_col = nil,
  })
end

-- Enhanced debugging keymaps
function M.setup_debug_keymaps()
  local dap = require("dap")
  local dapui = require("dapui")
  
  -- Debugging controls
  vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue" })
  vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over" })
  vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into" })
  vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out" })
  
  -- Breakpoints
  vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
  vim.keymap.set("n", "<leader>B", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "Conditional Breakpoint" })
  vim.keymap.set("n", "<leader>lp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
  end, { desc = "Log Point" })
  
  -- DAP UI controls
  vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
  vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
  vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
  vim.keymap.set("n", "<leader>dc", dap.clear_breakpoints, { desc = "Clear Breakpoints" })
  vim.keymap.set("n", "<leader>ds", dap.terminate, { desc = "Stop Debugging" })
  
  -- Language-specific debugging
  vim.keymap.set("n", "<leader>dpt", function()
    require("dap-python").test_method()
  end, { desc = "Debug Python Test" })
  vim.keymap.set("n", "<leader>dpc", function()
    require("dap-python").test_class()
  end, { desc = "Debug Python Class" })
  
  -- Visual mode for expression evaluation
  vim.keymap.set("v", "<M-k>", dapui.eval, { desc = "Evaluate Expression" })
end

-- Setup debugging signs/icons
function M.setup_debug_signs()
  vim.fn.sign_define("DapBreakpoint", {
    text = "",
    texthl = "DiagnosticSignError",
    linehl = "",
    numhl = "",
  })
  vim.fn.sign_define("DapBreakpointCondition", {
    text = "",
    texthl = "DiagnosticSignWarn",
    linehl = "",
    numhl = "",
  })
  vim.fn.sign_define("DapLogPoint", {
    text = "",
    texthl = "DiagnosticSignInfo",
    linehl = "",
    numhl = "",
  })
  vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "DiagnosticSignWarn",
    linehl = "Visual",
    numhl = "DiagnosticSignWarn",
  })
  vim.fn.sign_define("DapBreakpointRejected", {
    text = "",
    texthl = "DiagnosticSignHint",
    linehl = "",
    numhl = "",
  })
end

-- Main setup function for debugging
function M.setup()
  -- Install debugging adapters if they don't exist
  local dap = require("dap")
  
  -- Setup debugging for different languages
  M.setup_python_debugging()
  M.setup_js_debugging()
  
  -- Setup UI and enhancements
  M.setup_dap_ui()
  M.setup_virtual_text()
  M.setup_debug_signs()
  M.setup_debug_keymaps()
  
  vim.notify("IDE debugging configuration loaded", vim.log.levels.INFO)
end

return M