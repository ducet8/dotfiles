-- IDE Mode LSP Configuration
-- 2025.01.08 - Advanced LSP setup for your development stack
-- Enhanced configurations for Python, Shell, YAML, JSON, Terraform, Markdown, JS/TS

local M = {}

-- Enhanced LSP settings for each language server
local servers = {
  -- Python LSP with enhanced features
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          typeCheckingMode = "basic",
          autoImportCompletions = true,
        },
      },
    },
  },

  -- Alternative Python LSP (more feature-rich)
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = { enabled = false },
          mccabe = { enabled = false },
          pyflakes = { enabled = false },
          flake8 = { enabled = true },
          autopep8 = { enabled = false },
          yapf = { enabled = false },
          black = { enabled = true },
          isort = { enabled = true },
          mypy = { enabled = true },
          rope_completion = { enabled = true },
          rope_autoimport = { enabled = true },
        },
      },
    },
  },

  -- Shell/Bash LSP
  bashls = {
    filetypes = { "sh", "bash", "zsh" },
    settings = {
      bashIde = {
        globPattern = "**/*@(.sh|.inc|.bash|.command)",
      },
    },
  },

  -- YAML LSP with schema support
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://json.schemastore.org/docker-compose.yml"] = "/docker-compose*.yml",
          ["https://json.schemastore.org/kustomization.json"] = "/kustomization.yaml",
          ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
        },
        validate = true,
        completion = true,
        hover = true,
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
      },
    },
  },

  -- JSON LSP with schema support
  jsonls = {
    settings = {
      json = {
        validate = { enable = true },
      },
    },
    setup = {
      commands = {
        Format = {
          function()
            vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
          end,
        },
      },
    },
  },

  -- Terraform LSP
  terraformls = {
    filetypes = { "terraform", "hcl" },
    settings = {
      terraform = {
        experimentalFeatures = {
          validateOnSave = true,
          prefillRequiredFields = true,
        },
      },
    },
  },

  -- Terraform linter
  tflint = {
    filetypes = { "terraform" },
  },

  -- Markdown LSP
  marksman = {
    filetypes = { "markdown" },
    settings = {
      marksman = {
        completion = {
          wiki = {
            style = "title",
          },
        },
      },
    },
  },

  -- TypeScript/JavaScript LSP
  tsserver = {
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },

  -- ESLint for JavaScript/TypeScript
  eslint = {
    settings = {
      codeAction = {
        disableRuleComment = {
          enable = true,
          location = "separateLine",
        },
        showDocumentation = {
          enable = true,
        },
      },
      codeActionOnSave = {
        enable = false,
        mode = "all",
      },
      experimental = {
        useFlatConfig = false,
      },
      format = true,
      nodePath = "",
      onIgnoredFiles = "off",
      packageManager = "npm",
      problems = {
        shortenToSingleLine = false,
      },
      quiet = false,
      rulesCustomizations = {},
      run = "onType",
      useESLintClass = false,
      validate = "on",
      workingDirectory = {
        mode = "location",
      },
    },
  },

  -- Lua LSP for Neovim configuration
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
}

-- Enhanced none-ls (formatting/linting) configuration
function M.setup_null_ls()
  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    vim.notify("none-ls not available", vim.log.levels.WARN)
    return
  end
  
  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics
  local code_actions = null_ls.builtins.code_actions

  -- Create augroup for format on save
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  null_ls.setup({
    debug = false,
    sources = {
      -- Python (only include if tools are available)
      formatting.black,
      formatting.isort,
      diagnostics.flake8,

      -- Shell (conditional loading)
      formatting.shfmt,
      -- Skip shellcheck for now if causing issues
      -- diagnostics.shellcheck,

      -- YAML
      diagnostics.yamllint,

      -- JSON
      formatting.jq,

      -- Terraform
      formatting.terraform_fmt,

      -- Markdown
      diagnostics.markdownlint,

      -- JavaScript/TypeScript
      formatting.prettier.with({
        filetypes = { "javascript", "typescript", "json", "yaml", "html", "css", "scss", "vue" },
      }),

      -- General
      code_actions.gitsigns,
    },
    
    -- Format on save for IDE mode
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr })
          end,
        })
      end
    end,
  })
end

-- Enhanced LSP handlers for IDE mode
function M.setup_handlers()
  local handlers = require("user.lsp.handlers")
  
  -- Enhanced hover with better styling
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 80,
    max_height = 20,
  })

  -- Enhanced signature help
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
    close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
  })

  -- Enhanced completion with additional context
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- nvim-cmp capabilities
  local cmp_lsp = require("cmp_nvim_lsp")
  capabilities = cmp_lsp.default_capabilities(capabilities)
  
  -- Enhanced capabilities for IDE mode
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  return capabilities
end

-- Enhanced keymaps for IDE mode LSP features
function M.setup_ide_lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- Navigation
  vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
  vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
  vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
  
  -- Documentation
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  
  -- Code actions
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
  
  -- Diagnostics
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
  
  -- Workspace
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
end

-- Setup function for IDE mode LSP
function M.setup()
  local lspconfig = require("lspconfig")
  local capabilities = M.setup_handlers()
  
  -- Auto-install missing servers
  local mason_lspconfig = require("mason-lspconfig")
  mason_lspconfig.setup_handlers({
    -- Default handler
    function(server_name)
      local server_config = servers[server_name] or {}
      server_config.capabilities = capabilities
      server_config.on_attach = function(client, bufnr)
        M.setup_ide_lsp_keymaps(bufnr)
        
        -- Enable highlighting
        if client.server_capabilities.documentHighlightProvider then
          local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
          vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            group = group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end
      
      lspconfig[server_name].setup(server_config)
    end,
  })
  
  -- Setup none-ls for enhanced formatting/linting
  M.setup_null_ls()
  
  vim.notify("IDE LSP configuration loaded", vim.log.levels.INFO)
end

return M