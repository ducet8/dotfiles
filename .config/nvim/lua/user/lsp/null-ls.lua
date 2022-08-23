-- 2022.08.23 - ducet8@outlook.com

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

-- null_ls.setup({
-- 	debug = false,
-- 	sources = {
-- 		formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
-- 		formatting.black.with({ extra_args = { "--fast" } }),
-- 		formatting.stylua,
--     diagnostics.flake8,  -- Python linter
--     formatting.shfmt,  -- sh formatting (go install mvdan.cc/sh/v3/cmd/shfmt@latest)
--     diagnostics.shellcheck  -- sh linter (dnf/apt/brew install shellcheck)
-- 	},
-- })
null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.stylua,
    diagnostics.flake8,
    formatting.shfmt,
    diagnostics.shellcheck
	},
})
