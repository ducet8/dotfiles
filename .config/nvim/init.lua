-- 2025.05.27 - ducet8@outlook.com
-- Enhanced with dual-mode IDE system - 2025.01.08
-- https://github.com/LunarVim/Neovim-from-scratch

-- Bootstrap lazy.nvim and load minimal config first
require("user.lazy")

-- Initialize IDE system (sets up commands but doesn't load heavy features)
local ide = require("user.ide")
ide.setup()

-- Load minimal configuration (always loaded)
require("user.autocommands")
require("user.colorscheme")
require("user.cmp")
require("user.clipboard")
require("user.options")

-- Load basic keymaps for minimal mode
require("user.keymaps")

-- Note: The following modules are now loaded dynamically via :ide command
-- require("user.lsp")          -- Loaded in IDE mode
-- require("user.ft_indents")   -- Loaded in IDE mode
-- require("user.indentline")   -- Loaded in IDE mode
-- require("user.project")      -- Loaded in IDE mode

-- Notify user about available modes
vim.defer_fn(function()
  vim.notify("Neovim started in MINIMAL mode. Use :ide to enable IDE features.", vim.log.levels.INFO)
end, 100)
