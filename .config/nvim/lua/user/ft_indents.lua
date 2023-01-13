-- 2023.01.13 - ducet8@outlook.com

function ft_setter()
  local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
  if (ft == "java") or (ft == "python") or (ft == "sh") then
    vim.opt["shiftwidth"] = 4
    vim.opt["tabstop"] = 4
    print("Indentation using '4' for filetype: ", ft)
  elseif (ft == "c") or (ft == "cpp") or (ft == "go") then
    vim.opt["shiftwidth"] = 8
    vim.opt["tabstop"] = 8
    print("Indentation using '8' for filetype: ", ft)
  else
    print("Indentation using the default '2' for filetype: ", ft)
  end
end
    
vim.api.nvim_set_keymap("n", "<Leader>i", ":lua ft_setter()<CR>", { noremap = true, silent = true })
