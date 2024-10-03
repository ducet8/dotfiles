-- 2024.10.02 - ducet8@outlook.com
-- https://github.com/windwp/nvim-autopairs

return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    opts = {  -- this is equivalent to setup({}) function
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },

      -- cmp_autopairs = require("nvim-autopairs.completion.cmp"),
      -- cmp_status_ok, cmp = pcall(require, "cmp"),
      -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
  },
  config = [[require("nvim-autopairs.completion.cmp")], [require('config.cmp')]]
}