-- 2024.10.02 - ducet8@outlook.com
-- https://github.com/akinsho/toggleterm.nvim

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end
  
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
	size = 20,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
	  border = "curved",
	  winblend = 0,
	  highlights = {
	  border = "Normal",
		background = "Normal",
	  },
	},
  },
  config = function()
	require("toggleterm").setup()
  
	-- Set terminal keymaps
	vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  
	-- Now create and assign the terminals
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
	local node = Terminal:new({ cmd = "node", hidden = true })
	local ncdu = Terminal:new({ cmd = "ncdu", hidden = true })
	local htop = Terminal:new({ cmd = "htop", hidden = true })
	local python = Terminal:new({ cmd = "python", hidden = true })
  
	-- Define terminal toggle functions
	function _LAZYGIT_TOGGLE()
	  lazygit:toggle()
	end
  
	function _NODE_TOGGLE()
	  node:toggle()
	end
  
	function _NCDU_TOGGLE()
	  ncdu:toggle()
	end
  
	function _HTOP_TOGGLE()
	  htop:toggle()
	end
  
	function _PYTHON_TOGGLE()
	  python:toggle()
	end
  end
}