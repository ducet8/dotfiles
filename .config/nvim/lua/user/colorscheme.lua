-- 2025.05.27 - ducet8@outlook.com

-- Set colorscheme with proper error handling
local status_ok, _ = pcall(vim.cmd, "colorscheme gruvbox")
if not status_ok then
  vim.cmd("colorscheme default")
  vim.cmd("set background=dark")
end

-- Set transparent background after colorscheme is loaded
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { ctermbg = "NONE", bg = "NONE" })
  end,
})

-- Apply transparent background immediately if gruvbox loaded
if status_ok then
  vim.api.nvim_set_hl(0, "Normal", { ctermbg = "NONE", bg = "NONE" })
end