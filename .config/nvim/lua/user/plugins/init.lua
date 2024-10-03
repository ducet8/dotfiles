-- 2024.10.03 - ducet8@outlook.com

return {
  "nvim-lua/popup.nvim", -- An implementation of the Popup API from vim in Neovim
  -- "nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
  "kyazdani42/nvim-web-devicons",
  "moll/vim-bbye",
  "ahmedkhalf/project.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "antoinemadec/FixCursorHold.nvim", -- This is needed to fix lsp doc highlight

  -- Colorschemes
  "lunarvim/darkplus.nvim",
  "ellisonleao/gruvbox.nvim",

  -- cmp plugins
  "hrsh7th/nvim-cmp", -- The completion plugin
  "hrsh7th/cmp-buffer", -- buffer completions
  "hrsh7th/cmp-path", -- path completions
  "hrsh7th/cmp-cmdline", -- cmdline completions
  "saadparwaiz1/cmp_luasnip", -- snippet completions
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",

  -- snippets
  "L3MON4D3/LuaSnip", --snippet engine
  "rafamadriz/friendly-snippets", -- a bunch of snippets to use

  -- LSP
  "neovim/nvim-lspconfig", -- enable LSP
  "tamago324/nlsp-settings.nvim", -- language server settings defined in json for
  "williamboman/mason.nvim", -- simple to use language server installer
  "williamboman/mason-lspconfig.nvim", -- simple to use language server installer
  "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters

  "p00f/nvim-ts-rainbow",
  "JoosepAlviste/nvim-ts-context-commentstring",

  "ojroques/vim-oscyank",

  -- disable trouble
  -- { "folke/trouble.nvim", enabled = false },
}
