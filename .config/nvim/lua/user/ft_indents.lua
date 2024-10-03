-- 2024.10.03 - ducet8@outlook.com

function ft_setter()
  local ft = vim.bo.filetype
  if not ft or ft == "" then
    print("No filetype detected.")
    return
  end

  if (ft == "java") or (ft == "python") or (ft == "sh") then
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    print("Indentation using '4' for filetype: ", ft)
  elseif (ft == "yaml") or (ft == "yml") then
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    print("Indentation using '2' for filetype: ", ft)
  elseif (ft == "c") or (ft == "cpp") or (ft == "go") then
    vim.opt.shiftwidth = 8
    vim.opt.tabstop = 8
    print("Indentation using '8' for filetype: ", ft)
  else
    print("Indentation using the default '2' for filetype: ", ft)
  end
end

-- Keymap to trigger ft_setter
vim.api.nvim_set_keymap("n", "<Leader>i", ":lua ft_setter()<CR>", { noremap = true, silent = true })