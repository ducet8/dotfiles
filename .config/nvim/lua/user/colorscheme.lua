-- 2022.08.18 - ducet8@outlook.com

vim.cmd [[
try
  colorscheme gruvbox
  autocmd VimEnter * hi Normal ctermbg=none guibg=NONE  "Remove the milky appearance of gruvbox on transparent backgrounds
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
