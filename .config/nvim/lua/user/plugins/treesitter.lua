-- 2025.06.10 - ducet8@outlook.com

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
      },
      sync_install = false,
      ignore_install = {},  -- Empty table, not empty string
      highlight = {
        enable = true,
        disable = {},  -- Empty table, not empty string
        additional_vim_regex_highlighting = false,  -- Set to false for performance
      },
      indent = {
        enable = true,  -- Usually you want this on
        disable = {},
      },
    }
  end
}
