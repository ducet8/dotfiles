-- IDE Mode Documentation System
-- 2025.09.12 - Built-in help and documentation for IDE features
-- Provides interactive help accessible via :idehelp command

local M = {}

-- Main help content
local help_content = {
  header = [[
╔══════════════════════════════════════════════════════════════════════════════╗
║                            NEOVIM IDE MODE HELP                             ║
║                        Dual-Mode Neovim Configuration                       ║
╚══════════════════════════════════════════════════════════════════════════════╝

Welcome to your enhanced Neovim IDE! This system provides two modes:
• MINIMAL MODE: Fast, lightweight editing with basic features
• IDE MODE: Full development environment with advanced tools

]],

  modes = [[
┌─ MODE SWITCHING ─────────────────────────────────────────────────────────────┐
│ :ide        - Switch to IDE mode (loads all IDE features)                   │
│ :minimal    - Switch to minimal mode (lightweight)                          │
│ :idehelp    - Show this help                                                │
│ :idestatus  - Show current mode and loaded features                         │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  file_nav = [[
┌─ FILE NAVIGATION & SEARCH ──────────────────────────────────────────────────┐
│ <leader>e   - Toggle file explorer (Neo-tree)                              │
│ <leader>o   - Focus file explorer                                          │
│ <leader>ff  - Find files (Telescope)                                       │
│ <leader>fg  - Live grep (search in files)                                  │
│ <leader>fb  - Find buffers                                                 │
│ <leader>fr  - Recent files                                                 │
│ <leader>fp  - Find projects                                                │
│ <leader>/   - Advanced live grep with args                                 │
│ <leader>fw  - Find word under cursor                                       │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  lsp = [[
┌─ LSP & CODE INTELLIGENCE ───────────────────────────────────────────────────┐
│ gd          - Go to definition (Telescope)                                  │
│ gD          - Go to declaration                                             │
│ gi          - Go to implementation (Telescope)                              │
│ gt          - Go to type definition (Telescope)                             │
│ gr          - Find references (Telescope)                                   │
│ K           - Show hover documentation                                      │
│ <C-k>       - Show signature help                                          │
│ <leader>ca  - Code actions                                                 │
│ <leader>rn  - Rename symbol                                                │
│ <leader>f   - Format document                                              │
│ [d / ]d     - Previous/next diagnostic                                     │
│ <leader>e   - Show line diagnostics                                        │
│ <leader>q   - Show diagnostic list                                         │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  git = [[
┌─ GIT INTEGRATION ────────────────────────────────────────────────────────────┐
│ ]h / [h     - Next/previous git hunk                                        │
│ <leader>hs  - Stage hunk                                                   │
│ <leader>hr  - Reset hunk                                                   │
│ <leader>hS  - Stage entire buffer                                          │
│ <leader>hp  - Preview hunk                                                 │
│ <leader>hb  - Blame line                                                   │
│ <leader>tb  - Toggle line blame                                            │
│ <leader>gs  - Git status (Fugitive)                                        │
│ <leader>gc  - Git commit                                                   │
│ <leader>gp  - Git push                                                     │
│ <leader>gl  - Git pull                                                     │
│ <leader>gb  - Git blame                                                    │
│ <leader>gB  - Git branches (Telescope)                                     │
│ <leader>dv  - Open diff view                                               │
│ <leader>dh  - File history                                                 │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  debug = [[
┌─ DEBUGGING ──────────────────────────────────────────────────────────────────┐
│ <F5>        - Continue debugging                                            │
│ <F10>       - Step over                                                     │
│ <F11>       - Step into                                                     │
│ <F12>       - Step out                                                      │
│ <leader>b   - Toggle breakpoint                                            │
│ <leader>B   - Conditional breakpoint                                       │
│ <leader>dr  - Open REPL                                                    │
│ <leader>du  - Toggle DAP UI                                                │
│ <leader>dc  - Clear all breakpoints                                        │
│ <leader>ds  - Stop debugging                                               │
│ <leader>dpt - Debug Python test                                            │
│ <M-k>       - Evaluate expression (visual mode)                            │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  testing = [[
┌─ TESTING ────────────────────────────────────────────────────────────────────┐
│ <leader>tr  - Run nearest test                                              │
│ <leader>tf  - Run all tests in file                                        │
│ <leader>ts  - Stop running tests                                           │
│ <leader>to  - Show test output                                             │
│ <leader>tO  - Toggle test output panel                                     │
│ <leader>tS  - Toggle test summary                                          │
│ <leader>td  - Debug nearest test                                           │
│ ]t / [t     - Next/previous failed test                                    │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  terminal = [[
┌─ TERMINAL & TASKS ───────────────────────────────────────────────────────────┐
│ <C-\>       - Toggle terminal                                               │
│ <leader>tf  - Float terminal                                               │
│ <leader>th  - Horizontal terminal                                          │
│ <leader>tv  - Vertical terminal                                            │
│ <leader>or  - Run task (Overseer)                                          │
│ <leader>ot  - Toggle task list                                             │
│ <esc>       - Exit terminal mode                                           │
│ <C-h/j/k/l> - Navigate from terminal                                       │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  refactor = [[
┌─ REFACTORING & DOCUMENTATION ───────────────────────────────────────────────┐
│ <leader>rf  - Extract function (visual)                                    │
│ <leader>rv  - Extract variable (visual)                                    │
│ <leader>ri  - Inline variable                                              │
│ <leader>rb  - Extract block                                                │
│ <leader>nf  - Generate function documentation                              │
│ <leader>nc  - Generate class documentation                                 │
│ <leader>nt  - Generate type documentation                                  │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  utilities = [[
┌─ UTILITIES & QUICK ACTIONS ─────────────────────────────────────────────────┐
│ <leader>w   - Save file                                                    │
│ <leader>q   - Quit                                                         │
│ <leader>f   - Format document (works with YAML, JSON, Python, etc.)        │
│ <leader>fm  - Format document (IDE mode)                                   │
│ <leader>nh  - Clear search highlight                                       │
│ <leader>ln  - Toggle line numbers                                          │
│ <leader>tw  - Toggle word wrap                                             │
│ <leader>ts  - Toggle spell check                                           │
│ <leader>cp  - Copy file path                                               │
│ <leader>cf  - Copy file name                                               │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  languages = [[
┌─ LANGUAGE-SPECIFIC FEATURES ────────────────────────────────────────────────┐
│ Python:                                                                     │
│   <leader>rp - Run Python file        <leader>ri - Interactive Python      │
│   <leader>rP - Run pytest             LSP: pyright, pylsp                  │
│                                                                             │
│ Shell Scripts:                                                              │
│   <leader>rs - Run shell script       <leader>rc - Check with shellcheck   │
│   LSP: bashls                         Formatter: shfmt                     │
│                                                                             │
│ Terraform:                                                                  │
│   <leader>tf - Format                 <leader>tv - Validate                │
│   <leader>tp - Plan                   <leader>ta - Apply                   │
│   LSP: terraformls, tflint                                                 │
│                                                                             │
│ JavaScript/TypeScript:                                                      │
│   <leader>rn - Run with Node          <leader>rt - Run tests               │
│   <leader>rb - Build project          <leader>rd - Dev server              │
│   LSP: tsserver, eslint              Formatter: prettier                  │
│                                                                             │
│ YAML/JSON: Enhanced schema validation and formatting                       │
│ Markdown: Live preview and link checking                                   │
└──────────────────────────────────────────────────────────────────────────────┘

]],

  footer = [[
┌─ ADDITIONAL INFORMATION ────────────────────────────────────────────────────┐
│ • All IDE features are loaded on-demand for optimal performance            │
│ • Language servers are auto-installed via Mason                            │
│ • Debugging support for Python and JavaScript/TypeScript                  │
│ • Enhanced Git integration with visual diff tools                          │
│ • Comprehensive testing framework support                                  │
│ • Smart project management and workspace detection                         │
│                                                                             │
│ For detailed documentation: :help ide-mode                                 │
│ Report issues or suggestions in your dotfiles repository                   │
└──────────────────────────────────────────────────────────────────────────────┘

Press 'q' to close this help, or use ':q' to quit.
]],
}

-- Feature overview for quick reference
local feature_overview = {
  title = "IDE MODE FEATURE OVERVIEW",
  sections = {
    {
      name = "🗂️  FILE MANAGEMENT",
      items = {
        "Neo-tree file explorer with Git integration",
        "Telescope fuzzy finding for files, buffers, and content",
        "Project-aware navigation and workspace management",
        "Advanced search with live grep and regex support",
      }
    },
    {
      name = "💻 CODE INTELLIGENCE",
      items = {
        "LSP support for Python, Shell, YAML, JSON, Terraform, JS/TS, Markdown",
        "Auto-completion with context-aware suggestions",
        "Code actions, refactoring, and symbol navigation",
        "Real-time diagnostics and error checking",
      }
    },
    {
      name = "🐛 DEBUGGING",
      items = {
        "Python debugging with nvim-dap and debugpy",
        "JavaScript/TypeScript debugging with Chrome and Node.js",
        "Visual debugging with DAP UI and virtual text",
        "Breakpoints, watch expressions, and call stack inspection",
      }
    },
    {
      name = "🔧 GIT INTEGRATION",
      items = {
        "Gitsigns for hunk staging and blame information",
        "Fugitive for comprehensive Git operations",
        "Diffview for visual diff and merge conflict resolution",
        "Telescope Git integration for branches and commits",
      }
    },
    {
      name = "🧪 TESTING",
      items = {
        "Neotest framework with Python pytest support",
        "JavaScript/TypeScript testing with Jest",
        "Shell script testing support",
        "Test debugging and output visualization",
      }
    },
    {
      name = "📝 DOCUMENTATION",
      items = {
        "Neogen for automatic documentation generation",
        "Language-specific docstring templates",
        "Enhanced snippet management with LuaSnip",
        "Built-in help system for all IDE features",
      }
    },
  }
}

-- Keybinding quick reference
local keybinding_reference = {
  ["File Navigation"] = {
    ["<leader>e"] = "Toggle Explorer",
    ["<leader>ff"] = "Find Files",
    ["<leader>fg"] = "Live Grep",
    ["<leader>fb"] = "Find Buffers",
  },
  ["LSP"] = {
    ["gd"] = "Go to Definition",
    ["gr"] = "Find References", 
    ["K"] = "Hover Documentation",
    ["<leader>ca"] = "Code Actions",
    ["<leader>rn"] = "Rename",
    ["<leader>f"] = "Format Document",
  },
  ["Git"] = {
    ["<leader>gs"] = "Git Status",
    ["<leader>hs"] = "Stage Hunk",
    ["<leader>hp"] = "Preview Hunk",
    ["<leader>tb"] = "Toggle Blame",
  },
  ["Debug"] = {
    ["<F5>"] = "Continue",
    ["<F10>"] = "Step Over",
    ["<leader>b"] = "Toggle Breakpoint",
    ["<leader>du"] = "Toggle DAP UI",
  },
  ["Test"] = {
    ["<leader>tr"] = "Run Test",
    ["<leader>tf"] = "Run File Tests",
    ["<leader>td"] = "Debug Test",
    ["<leader>tS"] = "Test Summary",
  },
}

-- Troubleshooting guide
local troubleshooting = {
  title = "TROUBLESHOOTING GUIDE",
  common_issues = {
    {
      issue = "LSP server not starting",
      solutions = {
        "Run :LspInfo to check server status",
        "Run :Mason to install missing language servers",
        "Check if required dependencies are installed (python, node, etc.)",
        "Restart Neovim and try :ide command again",
      }
    },
    {
      issue = "Debugging not working",
      solutions = {
        "Ensure debugpy is installed for Python: pip install debugpy",
        "For Node.js, ensure you have a recent Node.js version",
        "Check :DapInstallInfo for debug adapter status",
        "Verify breakpoints are set in executable code",
      }
    },
    {
      issue = "Formatting not working",
      solutions = {
        "Run :Mason to install formatters (black, prettier, shfmt, etc.)",
        "Check null-ls configuration in ide/lsp.lua",
        "Verify formatter is available in PATH",
        "Try manual formatting with :lua vim.lsp.buf.format()",
      }
    },
    {
      issue = "Performance issues in IDE mode",
      solutions = {
        "Use :minimal command to return to lightweight mode",
        "Disable unused language servers in ide/lsp.lua",
        "Check for large files or directories in workspace",
        "Consider excluding node_modules or large build directories",
      }
    },
  }
}

-- Show main help window
function M.show_help()
  local buf = vim.api.nvim_create_buf(false, true)
  local content = {}
  
  -- Combine all help sections
  table.insert(content, help_content.header)
  table.insert(content, help_content.modes)
  table.insert(content, help_content.file_nav)
  table.insert(content, help_content.lsp)
  table.insert(content, help_content.git)
  table.insert(content, help_content.debug)
  table.insert(content, help_content.testing)
  table.insert(content, help_content.terminal)
  table.insert(content, help_content.refactor)
  table.insert(content, help_content.utilities)
  table.insert(content, help_content.languages)
  table.insert(content, help_content.footer)
  
  -- Split content into lines
  local lines = {}
  for _, section in ipairs(content) do
    for line in section:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "help")
  
  -- Create floating window
  local width = math.min(vim.o.columns - 4, 80)
  local height = math.min(vim.o.lines - 4, #lines + 2)
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " IDE Mode Help ",
    title_pos = "center",
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "cursorline", true)
  
  -- Add quit keymap
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
end

-- Show feature overview
function M.show_features()
  local lines = { "# " .. feature_overview.title, "" }
  
  for _, section in ipairs(feature_overview.sections) do
    table.insert(lines, "## " .. section.name)
    table.insert(lines, "")
    for _, item in ipairs(section.items) do
      table.insert(lines, "• " .. item)
    end
    table.insert(lines, "")
  end
  
  M._show_in_popup(lines, "Feature Overview")
end

-- Show keybinding reference
function M.show_keybindings()
  local lines = { "# KEYBINDING QUICK REFERENCE", "" }
  
  for category, bindings in pairs(keybinding_reference) do
    table.insert(lines, "## " .. category)
    table.insert(lines, "")
    for key, desc in pairs(bindings) do
      table.insert(lines, string.format("%-15s %s", key, desc))
    end
    table.insert(lines, "")
  end
  
  M._show_in_popup(lines, "Keybinding Reference")
end

-- Show troubleshooting guide
function M.show_troubleshooting()
  local lines = { "# " .. troubleshooting.title, "" }
  
  for _, item in ipairs(troubleshooting.common_issues) do
    table.insert(lines, "## " .. item.issue)
    table.insert(lines, "")
    for _, solution in ipairs(item.solutions) do
      table.insert(lines, "• " .. solution)
    end
    table.insert(lines, "")
  end
  
  M._show_in_popup(lines, "Troubleshooting")
end

-- Helper function to show content in popup
function M._show_in_popup(lines, title)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  
  local width = math.min(vim.o.columns - 4, 100)
  local height = math.min(vim.o.lines - 4, #lines + 2)
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })
  
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
end

-- Get status information
function M.get_status()
  local ide = require("user.ide")
  local status = {
    mode = ide.mode,
    loaded_plugins = vim.tbl_count(ide.loaded_plugins),
    lsp_clients = #vim.lsp.get_active_clients(),
    available_commands = { ":ide", ":minimal", ":idehelp", ":idestatus" },
  }
  return status
end

return M
