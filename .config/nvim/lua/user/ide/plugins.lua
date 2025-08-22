-- IDE Mode Plugins
-- 2025.01.08 - Enhanced IDE plugin configuration for dynamic loading
-- These plugins are loaded only when :ide command is executed

return {
  -- Enhanced LSP and Language Support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "jay-babu/mason-null-ls.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    lazy = true,
  },

  -- Advanced Language Servers for your tech stack
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        -- Python
        "pyright",
        "pylsp",
        -- Shell
        "bashls",
        -- YAML
        "yamlls",
        -- JSON
        "jsonls",
        -- Terraform
        "terraformls",
        "tflint",
        -- Markdown
        "marksman",
        -- JavaScript/TypeScript
        "tsserver",
        "eslint",
        -- Lua (for nvim config)
        "lua_ls",
      },
    },
    lazy = true,
  },

  -- Debugging Support
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      -- Python debugging
      "mfussenegger/nvim-dap-python",
      -- JavaScript/Node debugging  
      "mxsdev/nvim-dap-vscode-js",
    },
    lazy = true,
  },

  -- Enhanced Git Integration
  {
    "tpope/vim-fugitive",
    lazy = true,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    lazy = true,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
        },
      })
    end,
    lazy = true,
  },

  -- Project Management
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", "Makefile", "package.json", "requirements.txt", "Cargo.toml", "go.mod" },
        exclude_dirs = { "*/node_modules/*" },
      })
    end,
    lazy = true,
  },

  -- Code Navigation and Diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        icons = true,
        fold_open = "",
        fold_closed = "",
        use_diagnostic_signs = true,
      })
    end,
    lazy = true,
  },

  -- Code Refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
    lazy = true,
  },

  -- Testing Framework
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Python testing
      "nvim-neotest/neotest-python",
      -- JavaScript testing
      "nvim-neotest/neotest-jest",
      -- Shell testing  
      "rcasia/neotest-bash",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
          }),
          require("neotest-jest")({
            jestCommand = "npm test --",
            env = { CI = true },
          }),
          require("neotest-bash"),
        },
      })
    end,
    lazy = true,
  },

  -- Advanced Terminal Management
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        direction = "horizontal",
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
      })
    end,
    lazy = true,
  },

  -- Task Runner
  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup({
        templates = { "builtin", "user.python", "user.shell", "user.terraform" },
        task_list = {
          direction = "bottom",
          min_height = 25,
          max_height = 25,
          default_detail = 1,
        },
      })
    end,
    lazy = true,
  },

  -- Documentation Generation
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("neogen").setup({
        enabled = true,
        languages = {
          python = {
            template = {
              annotation_convention = "google_docstrings",
            },
          },
          javascript = {
            template = {
              annotation_convention = "jsdoc",
            },
          },
          typescript = {
            template = {
              annotation_convention = "tsdoc",
            },
          },
        },
      })
    end,
    lazy = true,
  },

  -- Enhanced Snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "honza/vim-snippets",
    },
    config = function()
      local luasnip = require("luasnip")
      -- Load snippets for IDE mode
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    lazy = true,
  },

  -- AI Code Assistance (Optional - uncomment if you use these services)
  -- {
  --   "github/copilot.vim",
  --   lazy = true,
  -- },
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "nvim-telescope/telescope.nvim"
  --   },
  --   lazy = true,
  -- },

  -- Enhanced File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = false,
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = true,
          },
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
        buffers = {
          follow_current_file = {
            enabled = true,
          },
        },
        git_status = {
          symbols = {
            added = "✚",
            modified = "",
            deleted = "✖",
            renamed = "",
            untracked = "",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
          },
        },
      })
    end,
    lazy = true,
  },

  -- Advanced Buffer Management
  {
    "famiu/bufdelete.nvim",
    lazy = true,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Language-Specific Enhancements
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "hcl" },
    config = function()
      vim.g.terraform_align = 1
      vim.g.terraform_fmt_on_save = 1
    end,
    lazy = true,
  },
  {
    "towolf/vim-helm",
    ft = "helm",
    lazy = true,
  },
  {
    "pearofducks/ansible-vim",
    ft = { "yaml", "yml" },
    lazy = true,
  },

  -- Code Formatting and Linting
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = true,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        -- Python
        "black",
        "isort", 
        "flake8",
        "mypy",
        -- Shell
        "shfmt",
        "shellcheck",
        -- YAML
        "yamllint",
        "yamlfix",
        -- JSON
        "jq",
        "fixjson",
        -- Terraform
        "terraform_fmt",
        "tflint",
        -- Markdown
        "markdownlint",
        -- JavaScript/TypeScript
        "prettier",
        "eslint_d",
        -- General
        "codespell",
      },
    },
    lazy = true,
  },
}