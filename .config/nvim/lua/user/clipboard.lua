-- 2025.05.27 - ducet8@outlook.com
-- Clipboard preservation mappings

-- Function to preserve clipboard content during delete operations
local function preserve_clipboard_delete(motion)
  -- Save current clipboard content
  local saved_clipboard = vim.fn.getreg('+')
  local saved_clipboard_type = vim.fn.getregtype('+')
  
  -- Perform the delete operation (goes to unnamed register)
  vim.cmd('normal! "' .. motion)
  
  -- Restore clipboard content
  vim.fn.setreg('+', saved_clipboard, saved_clipboard_type)
end

-- Key mappings that preserve clipboard
local keymap = vim.keymap.set

-- Delete operations that DON'T overwrite clipboard
keymap('n', '<leader>d', '"_d', { desc = 'Delete without affecting clipboard' })
keymap('v', '<leader>d', '"_d', { desc = 'Delete without affecting clipboard' })
keymap('n', '<leader>dd', '"_dd', { desc = 'Delete line without affecting clipboard' })
keymap('n', '<leader>D', '"_D', { desc = 'Delete to end of line without affecting clipboard' })

-- Change operations that DON'T overwrite clipboard  
keymap('n', '<leader>c', '"_c', { desc = 'Change without affecting clipboard' })
keymap('v', '<leader>c', '"_c', { desc = 'Change without affecting clipboard' })
keymap('n', '<leader>cc', '"_cc', { desc = 'Change line without affecting clipboard' })
keymap('n', '<leader>C', '"_C', { desc = 'Change to end of line without affecting clipboard' })

-- Cut operations that DO put content in clipboard (these replace clipboard)
keymap('n', '<leader>x', '"+d', { desc = 'Cut to clipboard' })
keymap('v', '<leader>x', '"+d', { desc = 'Cut to clipboard' })
keymap('n', '<leader>xx', '"+dd', { desc = 'Cut line to clipboard' })

-- Alternative: use black hole register by default, clipboard on demand
keymap('n', 'dd', '"_dd', { desc = 'Delete line to black hole register' })
keymap('n', 'D', '"_D', { desc = 'Delete to end of line to black hole register' })
keymap('v', 'd', '"_d', { desc = 'Delete selection to black hole register' })
keymap('n', 'c', '"_c', { desc = 'Change to black hole register' })
keymap('v', 'c', '"_c', { desc = 'Change selection to black hole register' })

-- Explicit clipboard operations
keymap('n', '<leader>y', '"+y', { desc = 'Yank to clipboard' })
keymap('v', '<leader>y', '"+y', { desc = 'Yank selection to clipboard' })
keymap('n', '<leader>p', '"+p', { desc = 'Paste from clipboard' })
keymap('n', '<leader>P', '"+P', { desc = 'Paste from clipboard before cursor' })

-- Toggle clipboard sync (like your vimrc F2)
local clipboard_enabled = true
local function toggle_clipboard()
  if clipboard_enabled then
    vim.opt.clipboard = ""
    clipboard_enabled = false
    print("Clipboard sync disabled")
  else
    vim.opt.clipboard = "unnamedplus"
    clipboard_enabled = true
    print("Clipboard sync enabled")
  end
end

keymap('n', '<F2>', toggle_clipboard, { desc = 'Toggle clipboard sync' })