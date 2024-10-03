-- 2024.10.02 - ducet8@outlook.com

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup {
      ensure_installed = {
        "bash", "c", "cmake", "css", "gitignore", "go", "gomod", "html", "http", "java",
        "javascript", "jsdoc", "json", "json5", "lua", "make", "markdown", "markdown_inline",
        "perl", "php", "python", "r", "regex", "ruby", "rust", "toml", "typescript", "vim", "yaml"
      }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
      ignore_install = { "" }, -- List of parsers to ignore installing
      autopairs = {
        enable = true,
      },
      highlight = {
        enable = true, -- false will disable the whole extension
        disable = { "" }, -- list of language that will be disabled
        additional_vim_regex_highlighting = true
      },
      indent = {
        enable = false,
        disable = { "" }
      },
      context_commentstring = {
        enable_autocmd = false,
      },
      rainbow = {
        enable = true,
        extended_mode = true,  -- Also highlight non-bracket type delimeters like HTML tags, boolean or table
        max_file_lines = nil  -- Do not enable for files with more than n lines, int
      }
    }
  end
}
