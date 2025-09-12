-- 2025.09.12 - ducet8@outlook.com

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	-- Try none-ls as fallback
	null_ls_status_ok, null_ls = pcall(require, "none-ls")
	if not null_ls_status_ok then
		return
	end
end

-- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({ 
			extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
			filetypes = { "javascript", "typescript", "json", "yaml", "html", "css", "scss", "vue", "markdown" }
		}),
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.stylua,
	   -- diagnostics.flake8, -- Disabled due to compatibility issues
	   formatting.shfmt,
	   -- diagnostics.shellcheck -- Disabled due to compatibility issues
	},
})
