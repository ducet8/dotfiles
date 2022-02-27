"
" global variables
"

" source .vimrc.first (before plugins)
if filereadable(".vimrc.first")
    source .vimrc.first
    echom "sourced .vimrc.first"
endif

" could be passed via cli, e.g. vim --cmd="let User_Dir='$HOME'"
if (!exists("User_Dir"))
    let User_Dir="~"
endif

"
" plugins
"

" only neovim & vim have autocmd (not ex or vi); vim-plug requires autocmd
if has("autocmd")
    " https://github.com/junegunn/vim-plug
    " auto-install .vim/autoload/plug.vim
    if empty(glob(User_Dir.'/.vim/autoload/plug.vim'))
        silent !curl -fLo  $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall
    endif

    if !empty(glob(User_Dir.'/.vim/autoload/plug.vim'))

        " autoload plug begin
        silent! call plug#begin(User_Dir.'/.vim/plug')

        if exists(":Plug")
            "
            " all versions of neovim & vim support these plugins
            "

            " https://github.com/ctrlpvim/ctrlp.vim
            Plug 'ctrlpvim/ctrlp.vim'
            let g:ctrlp_show_hidden = 1

            " https://github.com/luochen1990/rainbow
            Plug 'luochen1990/rainbow'
            let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

            " https://github.com/pseewald/vim-anyfold
            Plug 'pseewald/vim-anyfold'
            let g:anyfold_fold_comments=1
            " set foldlevel=0 " close all folds
            set foldlevel=99 " open all folds

            autocmd FileType * AnyFoldActivate

            " https://github.com/Raimondi/delimitMate
            Plug 'Raimondi/delimitMate'
            let delimitMate_matchpairs = "(:),[:],{:},<:>"
            autocmd FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"

            " https://github.com/sbdchd/neoformat
            Plug 'sbdchd/neoformat'
            "let g:neoformat_verbose = 1 " only affects the verbosity of Neoformat

            " https://github.com/zigford/vim-powershell
            Plug 'zigford/vim-powershell'

            if v:version >= 704
                "
                " all versions of neovim & vim >= 704 support these plugins
                "

                " https://github.com/scrooloose/nerdtree
                Plug 'scrooloose/nerdtree'
                let NERDTreeShowHidden=1
                autocmd StdinReadPre * let s:std_in=1
                "autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
                map <Leader>f :NERDTreeToggle<CR>
                let g:ctrlp_dont_split = 'NERD'
                let g:ctrlp_working_path_mode = 0  " don't change working directory
                " ignore these files and folders on file finder
                let g:ctrlp_custom_ignore = {
                  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
                  \ 'file': '\.pyc$\|\.pyo$',
                  \ }

                " https://github.com/sjl/gundo.vim
                " Using history, undofile, and undoleveles set below
                Plug 'sjl/gundo.vim'

            endif

            if v:version >= 800 || has('nvim')
                " https://github.com/dense-analysis/ale
                Plug 'dense-analysis/ale'
                let g:ale_linters = { 'php': ['php'], }
                let g:ale_lint_on_save = 1
                let g:ale_lint_on_text_changed = 0

                if has('nvim')
                    " https://github.com/sheerun/vim-polyglot 
                    " doesn't seem to work with vim 8.0 1-1763
                    Plug 'sheerun/vim-polyglot'
                endif

            elseif v:version >= 704
                " https://github.com/chrisbra/vim-sh-indent
                Plug 'chrisbra/vim-sh-indent'

                " https://github.com/pearofducks/ansible-vim
                Plug 'pearofducks/ansible-vim'
                let g:ansible_unindent_after_newline = 1
                autocmd BufNewFile,BufRead *.{j2,jinja2,yaml,yml} set filetype=yaml.ansible
                autocmd Filetype yaml.ansible setlocal ai ts=2 sts=2 sw=2 expandtab

                " https://github.com/vim-syntastic/syntastic
                Plug 'scrooloose/syntastic'
                let g:syntastic_always_populate_loc_list = 1
                let g:syntastic_auto_loc_list = 1
                let g:syntastic_check_on_open = 1
                let g:syntastic_check_on_wq = 0
                let g:syntastic_yaml_checkers = ['yamllint']
            endif

            " https://github.com/tpope/vim-fugitive
            Plug 'tpope/vim-fugitive'

            " https://github.com/tpope/vim-sensible
            Plug 'tpope/vim-sensible'

            " https://github.com/vim-airline/vim-airline
            Plug 'vim-airline/vim-airline'
            "let g:airline_powerline_fonts = 1
            let g:airline_detect_spellang=0

            " https://github.com/preservim/nerdcommenter
            Plug 'scrooloose/nerdcommenter'
            let g:NERDCreateDefaultMappings = 1             " Create default mappings
            let g:NERDSpaceDelims = 1                       " Add spaces after comment delimiters
            let g:NERDCompactSexyComs = 1                   " Use compact syntax for prettified multi-line comments
            let g:NERDDefaultAlign = 'left'                 " Left justify comment delimiters
            let g:NERDCommentEmptyLines = 1                 " Allow commenting and inverting empty lines
            let g:NERDTrimTrailingWhitespace = 1            " Enable trimming of trailing whitespace when uncommenting
            let g:NERDToggleCheckAllLines = 1               " Enable checking if selected lines are commented
            let g:NERDTreeIgnore = ['\.pyc$', '\.pyo$']     " Filetypes to be ignored

            " https://github.com/Xuyuanp/nerdtree-git-plugin
            Plug 'Xuyuanp/nerdtree-git-plugin'

            " https://github.com/mhinz/vim-signify
            if has('nvim') || has('patch-8.0.902')
            	Plug 'mhinz/vim-signify'
            else
            	Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
            endif

            if v:version >= 800 || has('nvim')
                " vim 8+ or neovim, only

                " https://github.com/fatih/vim-go
                Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
                let g:go_version_warning = 0
                let g:go_fmt_command = "goimports"
                let g:go_def_mode = "gopls"
                let g:go_def_mapping_enabled = 0
                let g:go_info_mode = "gopls"
                autocmd BufNewFile,BufRead *.go set filetype=go expandtab!
                let g:go_fmt_autosave = 0
                let g:go_fmt_fail_silently = 1
                "autocmd FileType go map <C-n> :cnext<CR>
                "autocmd FileType go map <C-m> :cprevious<CR>
                "autocmd FileType go nnoremap <leader>a :cclose<CR>
                "autocmd FileType go nmap <leader>b <Plug>(go-build)
                "autocmd FileType go nmap <leader>i <Plug>(go-imports)
                "autocmd FileType go nmap <leader>r <Plug>(go-run)
                "autocmd FileType go nmap <leader>t <Plug>(go-test)
                "autocmd FileType go nmap <leader>c <Plug>(go-coverage)

                let use_coc = 0 " false
                let use_ycm = 1 " true

                if v:version >= 800 || has('nvim-0.3.1')

                    if executable('node')
                        let node_output = system('node' . ' --version')
                        let node_ms = matchlist(node_output, 'v\(\d\+\).\(\d\+\).\(\d\+\)')
                        if empty(node_ms) || str2nr(node_ms[1]) < 12
                            let use_coc = 0
                            let use_ycm = 1
                        else
                            let use_coc = 1
                            let use_ycm = 0
                        endif
                    endif

                    if use_coc
                        " https://github.com/neoclide/coc.nvim
                        " release branch
                        Plug 'neoclide/coc.nvim', {'branch': 'release'}
                        " latest tag
                        " Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}

                        " Use tab for trigger completion with characters ahead and navigate.
                        " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
                        inoremap <silent><expr> <TAB>
                                    \ pumvisible() ? "\<C-n>" :
                                    \ <SID>check_back_space() ? "\<TAB>" :
                                    \ coc#refresh()
                        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

                        function! s:check_back_space() abort
                            let col = col('.') - 1
                            return !col || getline('.')[col - 1]  =~# '\s'
                        endfunction

                        " Use <c-space> to trigger completion.
                        if has('nvim')
                            inoremap <silent><expr> <c-space> coc#refresh()
                        else
                            inoremap <silent><expr> <c-@> coc#refresh()
                        endif

                        " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
                        " Coc only does snippet and additional edit on confirm.

                        " Use `[c` and `]c` to navigate diagnostics
                        nmap <silent> [c <Plug>(coc-diagnostic-prev)
                        nmap <silent> ]c <Plug>(coc-diagnostic-next)

                        " Remap keys for gotos
                        nmap <silent> gd <Plug>(coc-definition)
                        nmap <silent> gy <Plug>(coc-type-definition)
                        nmap <silent> gi <Plug>(coc-implementation)
                        nmap <silent> gr <Plug>(coc-references)

                        " Use K to show documentation in preview window
                        nnoremap <silent> K :call <SID>show_documentation()<CR>

                        function! s:show_documentation()
                            if (index(['vim','help'], &filetype) >= 0)
                                execute 'h '.expand('<cword>')
                            else
                                call CocAction('doHover')
                            endif
                        endfunction

                        " Highlight symbol under cursor on CursorHold
                        autocmd CursorHold * silent call CocActionAsync('highlight')

                        " Remap for rename current word
                        nmap <leader>rn <Plug>(coc-rename)

                        " Remap for format selected region
                        xmap <leader>f  <Plug>(coc-format-selected)
                        nmap <leader>f  <Plug>(coc-format-selected)

                        augroup mygroup
                            autocmd!
                            " Setup formatexpr specified filetype(s).
                            autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
                            " Update signature help on jump placeholder
                            autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
                        augroup end

                        " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
                        xmap <leader>a  <Plug>(coc-codeaction-selected)
                        nmap <leader>a  <Plug>(coc-codeaction-selected)

                        " Remap for do codeAction of current line
                        nmap <leader>ac  <Plug>(coc-codeaction)
                        " Fix autofix problem of current line
                        nmap <leader>qf  <Plug>(coc-fix-current)

                        " Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
                        nmap <silent> <TAB> <Plug>(coc-range-select)
                        xmap <silent> <TAB> <Plug>(coc-range-select)
                        xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

                        " Use `:Format` to format current buffer
                        command! -nargs=0 Format :call CocAction('format')

                        " Use `:Fold` to fold current buffer
                        command! -nargs=? Fold :call     CocAction('fold', <f-args>)

                        " Use `:OR` for organize import of current buffer
                        command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

                        " Add status line support, for integration with other plugin, checkout `:h coc-status`
                        set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

                        " Using CocList
                        nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>   " Show all diagnostics
                        nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>    " Manage extensions
                        nnoremap <silent> <space>c  :<C-u>CocList commands<cr>      " Show commands
                        nnoremap <silent> <space>o  :<C-u>CocList outline<cr>       " Find symbol of current document
                        nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>    " Search workspace symbols
                        nnoremap <silent> <space>j  :<C-u>CocNext<CR>               " Do default action for next item.
                        nnoremap <silent> <space>k  :<C-u>CocPrev<CR>               " Do default action for previous item.
                        nnoremap <silent> <space>p  :<C-u>CocListResume<CR>         " Resume latest coc list

                        " Warnings
                        let g:coc_disable_startup_warning = 1

                        " Colors
                        highlight CocErrorHighlight ctermfg=red  guifg=red

                        " Extensions
                        if v:version >= 800 || has('nvim')
                            " add coc-snippets
                            let g:coc_global_extensions=[ 'coc-css', 'coc-gitignore', 'coc-go', 'coc-html', 'coc-json', 'coc-phpls', 'coc-powershell', 'coc-pyright', 'coc-sh', 'coc-tsserver', 'coc-yaml', 'coc-snippets' ]
                        else
                            let g:coc_global_extensions=[ 'coc-css', 'coc-gitignore', 'coc-go', 'coc-html', 'coc-json', 'coc-phpls', 'coc-powershell', 'coc-pyright', 'coc-sh', 'coc-tsserver', 'coc-yaml' ]
                        endif

                        if (exists("PYTHONPATH"))
                            let g:python3_host_prog=$PYTHONPATH
                        endif
                        let g:loaded_python_provider = 0
                    endif  " if use_coc

                else  " if v:version >= 800 || has('nvim-0.3.1')
                    " https://github.com/suan/vim-instant-markdown
                    Plug 'suan/vim-instant-markdown'
                    let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']
                    let g:markdown_syntax_conceal = 0
                    let g:markdown_minlines = 100
                    let g:instant_markdown_autostart = 0  " Use :InstantMarkdownPreview to turn on
                endif  " if v:version >= 800 || has('nvim-0.3.1')

                if use_ycm
                    if v:version < 810
                        let use_ycm = 0  " false
                    endif
                endif  " if use_ycm

                if use_ycm
                    " https://github.com/Valloric/YouCompleteMe
                    Plug 'Valloric/YouCompleteMe'
                    "let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
                    "let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
                    "let g:SuperTabDefaultCompletionType = '<C-n>'
                endif  " if use_ycm

            endif  " if v:version >= 800 || has('nvim')

        else " if exists(":Plug")
            echo "Plug does not exist."
        endif  " if exists(":Plug")

        " autoload plug begin
        call plug#end()

    endif

    " autocmd Buf preferences
    autocmd BufNewFile,BufRead *.d set filetype=sh
    autocmd BufNewFile,BufRead *.env set filetype=sh
    autocmd BufNewFile,BufRead *.md set filetype=markdown
    autocmd BufNewFile,BufRead http* set filetype=xml syntax=apache
    autocmd BufNewFile,BufRead named*.conf set filetype=named
    autocmd BufNewFile,BufRead *.web set filetype=sh
    autocmd BufNewFile,BufRead *.zone set filetype=bindzone

    " autocmd Vim preferences
    "autocmd VimEnter * "set term=$TERM"

    if has('nvim')
        " workaround nvim terminal bug; https://github.com/neovim/neovim/wiki/FAQ#nvim-shows-weird-symbols-2-q-when-changing-modes
        autocmd OptionSet guicursor noautocmd set guicursor=
        set guicursor=
    endif

endif  "has("autocmd")

"
" functions
"

" call ctags a few different ways
function! CtagsUpdate(scope)
    let ctags_command=""

    if a:scope == 'directory'
        " tags for all files in the directory of the buffer
        let ctags_command="!ctags --fields=+l -f " .expand('%:p:h'). "/.tags ".expand('%:p:h')."/*"
    elseif a:scope == 'recursive'
        " tags for all files in the directory of the buffer, recursively
        let ctags_command="!ctags --fields=+l -f " .expand('%:p:h'). "/.tags ".expand('%:p:h')."/* -R --append"
    else
        " tags for the current file in the buffer
        let ctags_command="!ctags --fields=+l --append --language-force=" . &filetype . " -f " .expand('%:p:h'). "/.tags " . expand('%:p') . " &> /dev/null"
    endif

    " silently execute the command
    :silent execute l:ctags_command | execute 'redraw!'

    " echo something useful
    echo "Updated (" . a:scope . ") tags in " . expand('%:p:h') . "/.tags"
endfunction

set tags+=.tags;/                           " search backwards for .tags (too)
command! CtagsFile call CtagsUpdate('file')
command! CtagsDirectory call CtagsUpdate('directory')
command! CtagsRecursive call CtagsUpdate('recursive')
map <Leader>ctd :CtagsDirectory<CR>
map <Leader>ctf :CtagsFile<CR>
map <Leader>ctr :CtagsRecursive<CR>
map <Leader>ctu :CtagsUpdate<CR>

" preserve cursor et al and indent the whole buffer
if !exists("*IndentBuffer")
    function! IndentBuffer()
        call PreserveCursor('normal gg=G')
    endfunction
    map <F8> :call IndentBuffer()<CR>
endif

" restore cursor position, window position, and the last search after running a command
if !exists("*PreserveCursor")
    function! PreserveCursor(command)
        " save the last search
        let search = @/

        " save the current cursor position
        let cursor_position = getpos('.')

        " save the current window position
        normal! H
        let window_position = getpos('.')
        call setpos('.', cursor_position)

        " execute the command
        execute a:command

        " restore the last search
        let @/ = search

        " restore the previous window position
        call setpos('.', window_position)
        normal! zt

        " restore the previous cursor position
        call setpos('.', cursor_position)
    endfunction
endif

" reconfigure/reload (source) .vimrc
if !exists("*Reconfigure")
    function Reconfigure()
        :execute ":source " . g:User_Dir . "/.vimrc"
        if has("gui_running")
            :execute ":source " . g:User_Dir . "/.gvimrc"
        endif
    endfunction

    command! Reconfigure call Reconfigure()
    map <Leader>s :call Reconfigure()<CR>
endif

" show highlight under cursor (or just use :hi to see the whole list)
function! SynStack ()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction
map <Leader>h :call SynStack()<CR>

if !exists("*ToggleClipboard")
    function! ToggleClipboard()
        if &clipboard ==# "unnamedplus"
            set clipboard&
            echo "Clipboard turned off."
        else
            set clipboard=unnamedplus
            echo "Clipboard turned on."
        endif
    endfunction
endif

if !exists("*ToggleListchars")
    function! ToggleListchars()
        set invlist
    endfunction
endif

if !exists("*TogglePaste")
    function TogglePaste()
        if &paste
            set nopaste
            echo "Paste turned off."
        else
            set paste
            echo "Paste turned on."
        endif
    endfunction
endif

if !exists("*ToggleSpell")
    function ToggleSpell()
        if &spell
            set nospell
            echo "Spell turned off."
        else
            set spell spelllang=en_us
            echo "Spell turned on."
        endif
    endfunction
endif

" NR-8    COLOR NAME
" 0       Black
" 1       DarkRed
" 2       DarkGreen
" 3       Brown, DarkYellow
" 4       DarkBlue
" 5       DarkMagenta
" 6       DarkCyan
" 7       LightGray, LightGrey, Gray, Grey
" 8       DarkGray, DarkGrey
" 9       Red, LightRed
" 10      Green, LightGreen
" 11      Yellow, LightYellow
" 12      Blue, LightBlue
" 13      Magenta, LightMagenta
" 14      Cyan, LightCyan
" 15      White

"
" preferences
"

" only set t_Co for older versions of vim
if v:version < 800 || !has('nvim')
    if &t_Co
        set t_Co=256
    endif
endif

" if possible, enable true color
if exists('+termguicolors')
    set termguicolors
    " for termguicolors, set correct RGB escape codes for various non-nvim terminals
    if !has('nvim')
        if $TERM ==# 'ansi' || $TERM =~ '256col'
            let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
            let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        endif
    endif
endif

" customize colors (before loading colorscheme)
func! s:customize_colors() abort
    " https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
    " http://vimdoc.sourceforge.net/htmldoc/syntax.html#syncolor
    " NR-16; 0=black 1=darkred, 2=darkgreen, 3=brown, 4=darkblue, 5=darkmagenta, 6=darkcyan, 7=grey, 8=boldgrey, 9=boldred, 10=boldgreen, 11=yellow, 12=boldblue, 13=magenta, 14=cyan, 15=lightgrey, 16=black
    hi ALEError ctermfg=white ctermbg=red guifg=white guibg=red
    hi Comment ctermfg=grey guifg=grey
    hi Constant ctermfg=white guifg=white
    hi ErrorMsg ctermfg=white ctermbg=red guifg=white guibg=red
    hi Identifier ctermfg=green guifg=green1
    hi Operator ctermfg=grey
    hi Pmenu ctermfg=white ctermbg=blue guifg=white guibg=blue
    hi Special ctermfg=yellow
    hi PmenuSel guifg=black guibg=yellow
    hi PmenuSbar guifg=white guibg=green
    hi PmenuThumb guifg=yellow guibg=black
    hi shDeref guifg=yellow
    hi bashStatement guifg=darkkhaki
    hi shConditional guifg=deepskyblue
    hi CursorLine guibg=NONE
    "hi shDerefSimple guifg=yellow
    set cursorline
    if !has('nvim')
        set cursorlineopt=number
    endif
    if $USER == 'root'
        hi LineNr guifg=red
    else
        hi LineNr guifg=grey
    fi
    hi CursorLineNR cterm=bold ctermfg=Yellow gui=bold guifg=Yellow
endfunc

augroup customize_colorscheme | au!
    au ColorScheme * call s:customize_colors()
augroup END

" color preferences
silent! colorscheme elford
set background=dark

" syntax preferences
syntax on
syntax enable

" filetype preferenes
filetype plugin indent on

" indent folding with manual folds
augroup vimrc
    au BufReadPre * setlocal foldmethod=indent
    au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
augroup END

" keyboard preferences
noremap <silent> <F2> <Esc>:call ToggleClipboard()<CR>
noremap <silent> <F3> <Esc>:call ToggleSpell()<CR>
noremap <silent> <F4> <Esc>:call TogglePaste()<CR>
" <F8> is conditionally mapped to IndentBuffer() (above)
if (&ft == 'json')
    map <F8> :%!python -m json.tool<CR>   " format/indent json better
endif
noremap <F6> <Esc>:syntax sync fromstart<CR>
inoremap <F5> <C-O>za
nnoremap <F5> za
onoremap <F5> <C-C>za
vnoremap <F5> zf
noremap <F12> <Esc>:Explore<CR>
noremap <silent> <F9> <Esc>:call ToggleListchars()<CR>
nnoremap qb :silent! normal mpea}<Esc>bi{<Esc>`pl " put {} (braces) around a word
map <Leader><F8> :%!python -m json.tool<CR>   " format/indent json better
map <Leader>q :q<CR>
map <Leader>t gt

" use \sp (<leader> sp) to show the syntx group under the cursor
nmap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" setting preferences
set autoindent                              " copy indet from current line when starting a new line
set autoread                                " automatically re-read files that have changed outside of VIM
set backspace=indent,eol,start              " allow backspace in insert mode
set clipboard=unnamedplus                   " Set default clipboard name ;
set complete-=i                             " do not complete for included files; .=current buffer, w=buffers in other windows, b=other loaded buffers, u=unloaded buffers, t=tags, i=include files
set directory=~/.config/tmp/$HOSTNAME       " where to store swap files
set noerrorbells                            " turn off error bells
set expandtab                               " use spaces for tabs, not <Tab>
set exrc                                    " source .exrc in the current directory (use .exrc for both vim/nvim compatibility, not .vimrc or .nvimrc)
set formatoptions=tcq                       " t=auto-wrap text, c=auto-wrap comments, q=allow comments formatting with
if v:version >= 704
    set formatoptions=j                     " j=remove comment leader when joining lines
endif
set hidden                                  " allow hidden buffers
set history=100                             " default = 8
set laststatus=2                            " use the second statusline
set linebreak                               " only wrap at sensible places
set list listchars=tab:│\ ,nbsp:▪,trail:▫,extends:▶,precedes:◀ " help listchars
set nocompatible                            " make vim behave in a more useful way
set number                                  " line numbers
set ruler                                   " show the line and column number of the cursor position
set secure                                  " shell and write commands are not allowed in .nvimrc and .exrc in the current directory
set shiftwidth=4                            " return value for shiftwidth()
set showbreak=↪\                            " show line breaks (wrap)
set showcmd                                 " show (partial) command in the last line of the screen
"set signcolumn=yes                          " always show signcolumns
"set smartindent                             " smart autoindent when starting a new line; shouldn't use with filtetype indent
set smarttab                                " when on a <Tab> in front of a line, insert blanks according to shiftwidth
set softtabstop=4                           " default tabs are too big
set tabstop=4                               " default tabs are too big
set textwidth=0                             " prevent vim from automatically inserting line breaks
if has ("title")
    set titlestring=[vi\ %t]\ %{$USER}@%{hostname()}:%F " :h statusline
    set title                               " set term title
    set titleold=                           " uset term title"
endif
set ttyfast                                 " indicates a fast terminal connection
if exists("&undodir")
    set undodir=~/.vim/undo                 " set undo directory location
endif
set undofile                                " gundo
set undolevels=100                          " gundo
set updatetime=300                          " diagnostic messages
set wildmenu                                " enhanced command-line completion
set wrap                                    " turn on word wrapping
set wrapmargin=0                            " number of characters from the right window border where wrapping starts

" source .vimrc.last (override anything)
if filereadable(".vimrc.last")
    source .vimrc.last
    echom "sourced .vimrc.last"
endif
