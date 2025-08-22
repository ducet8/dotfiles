-- IDE Mode Controller
-- 2025.01.08 - Enhanced by Roo for dual-mode Neovim setup
-- Provides on-demand loading of IDE features while keeping minimal mode fast

local M = {}

-- Track current mode state
M.mode = "minimal"
M.loaded_plugins = {}

-- IDE mode indicator for statusline
function M.get_mode_indicator()
  if M.mode == "ide" then
    return "󰅂 IDE"
  else
    return "󰅂 MIN"
  end
end

-- Safely require a module with error handling
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Failed to load: " .. module .. "\nError: " .. result, vim.log.levels.ERROR)
    return nil
  end
  return result
end

-- Load IDE-specific plugins and configurations
function M.load_ide_features()
  if M.mode == "ide" then
    vim.notify("IDE mode already active", vim.log.levels.INFO)
    return
  end

  vim.notify("Loading IDE features...", vim.log.levels.INFO)
  
  -- Set mode to IDE first
  M.mode = "ide"
  
  -- Load IDE plugins explicitly by name
  local lazy = require("lazy")
  local ide_plugins = {
    -- Enhanced LSP
    "nlsp-settings.nvim",
    "none-ls.nvim",
    "mason-null-ls.nvim",
    "schemastore.nvim",
    
    -- Project Management
    "project.nvim",
    
    -- Debugging
    "nvim-dap",
    "nvim-dap-ui",
    "nvim-dap-virtual-text",
    "nvim-nio",
    "nvim-dap-python",
    "nvim-dap-vscode-js",
    
    -- Git Integration
    "vim-fugitive",
    "diffview.nvim",
    "gitsigns.nvim",
    
    -- Code Tools
    "trouble.nvim",
    "refactoring.nvim",
    
    -- Testing
    "neotest",
    "neotest-python",
    "neotest-jest",
    "neotest-bash",
    
    -- Terminal & Tasks
    "toggleterm.nvim",
    "overseer.nvim",
    
    -- Documentation
    "neogen",
    
    -- File Management
    "neo-tree.nvim",
    "bufdelete.nvim",
    
    -- Language Support
    "vim-terraform",
    "vim-helm",
    "ansible-vim",
  }
  
  -- Load plugins with error handling
  for _, plugin in ipairs(ide_plugins) do
    pcall(lazy.load, { plugins = { plugin } })
  end
  
  -- Wait a moment for plugins to initialize, then load configurations
  vim.defer_fn(function()
    -- Load IDE-specific configurations with error handling
    local keymaps = safe_require("user.ide.keymaps")
    if keymaps then
      keymaps.setup()
    end
    safe_require("user.lsp")
    safe_require("user.project")
    
    -- Setup debugging if available
    if pcall(require, "dap") then
      safe_require("user.ide.debugging")
    end
    
    -- Setup advanced LSP if available
    if pcall(require, "mason") then
      safe_require("user.ide.lsp")
    end
    
    -- Refresh statusline to show IDE indicator
    if package.loaded["lualine"] then
      require("lualine").refresh()
    end
    
    vim.notify("IDE mode activated! Type :idehelp for features overview", vim.log.levels.INFO)
  end, 200)
end

-- Return to minimal mode (unload heavy features)
function M.load_minimal_features()
  if M.mode == "minimal" then
    vim.notify("Already in minimal mode", vim.log.levels.INFO)
    return
  end

  vim.notify("Switching to minimal mode...", vim.log.levels.INFO)
  
  -- Note: Full unloading of plugins is complex in Neovim
  -- For now, we'll just update mode state and disable heavy features
  M.mode = "minimal"
  
  -- Refresh statusline
  if package.loaded["lualine"] then
    require("lualine").refresh()
  end
  
  vim.notify("Minimal mode activated. Restart nvim for full minimal experience.", vim.log.levels.WARN)
end

-- Show help for IDE features
function M.show_help()
  local help_content = safe_require("user.ide.docs")
  if help_content then
    help_content.show_help()
  else
    vim.notify("IDE help not available", vim.log.levels.ERROR)
  end
end

-- Show current status
function M.show_status()
  local status = string.format([[
Current Mode: %s
Loaded Plugins: %d
Available Commands:
  :ide      - Switch to IDE mode
  :minimal  - Switch to minimal mode  
  :idehelp  - Show features help
  :idestatus - Show this status
]], M.mode:upper(), vim.tbl_count(M.loaded_plugins))
  
  vim.notify(status, vim.log.levels.INFO)
end

-- Setup function to register commands
function M.setup()
  -- Create user commands (Neovim requires uppercase, but we'll add convenience aliases)
  vim.api.nvim_create_user_command("IDE", M.load_ide_features, {
    desc = "Load IDE features dynamically"
  })
  
  vim.api.nvim_create_user_command("Minimal", M.load_minimal_features, {
    desc = "Switch to minimal mode"
  })
  
  vim.api.nvim_create_user_command("IdeHelp", M.show_help, {
    desc = "Show IDE features help"
  })
  
  vim.api.nvim_create_user_command("IdeStatus", M.show_status, {
    desc = "Show current IDE mode status"
  })
  
  -- Create convenient lowercase aliases using command abbreviations
  vim.cmd([[
    cnoreabbrev <expr> ide (getcmdtype() == ':' && getcmdline() == 'ide') ? 'IDE' : 'ide'
    cnoreabbrev <expr> minimal (getcmdtype() == ':' && getcmdline() == 'minimal') ? 'Minimal' : 'minimal'
    cnoreabbrev <expr> idehelp (getcmdtype() == ':' && getcmdline() == 'idehelp') ? 'IdeHelp' : 'idehelp'
    cnoreabbrev <expr> idestatus (getcmdtype() == ':' && getcmdline() == 'idestatus') ? 'IdeStatus' : 'idestatus'
  ]])
end

return M