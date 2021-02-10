let g:python_host_prog = $PYENV_ROOT.'/versions/neovim2/bin/python'
let g:python3_host_prog = expand('$HOME') . '/.anyenv/envs/pyenv/shims/python'
let g:node_host_prog =  expand('$HOME') . '.anyenv/envs/nodenv//shims/neovim-node-host'

let g:NVIM_NODE_LOG_FILE ='/tmp/log/node/nvim.log'

augroup TransparentBG
  autocmd!
  autocmd Colorscheme * highlight Normal ctermbg=none
  autocmd Colorscheme * highlight NonText ctermbg=none
  autocmd Colorscheme * highlight LineNr ctermbg=none
  autocmd Colorscheme * highlight Folded ctermbg=none
  autocmd Colorscheme * highlight EndOfBuffer ctermbg=none
augroup END

syntax on
scriptencoding utf-8
set synmaxcol=200
set autoindent
set modifiable
set smartindent
set nobackup
set directory=~/.vim/tmp
set clipboard+=unnamedplus
set undodir=D:/home/koron/var/vim/undo
set tabstop=2
set shiftwidth=2
set expandtab
set smarttab
set shiftround
set nocursorline
set number
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double
set wildmenu
set history=5000
set whichwrap=b,s,<,>,[,]
set showtabline=2
set nospell
set ttimeout
set ttimeoutlen=50
set list
set listchars=tab:»-,trail:-,nbsp:%,eol:↲
set ignorecase
set smartcase
set wrapscan
set incsearch
set inccommand=split

" imap
imap { {}<LEFT>
imap [ []<LEFT>
imap ( ()<LEFT>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

tnoremap <silent> <ESC> <C-\><C-n>


nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sn gt
nnoremap sp gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>
nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>

autocmd InsertLeave * set nopaste
autocmd QuickFixCmdPost vimgrep cwindow
autocmd QuickFixCmdPost *grep* cwindow

let mapleader = "\<Space>"

" 起動時設定
au BufRead,BufNewFile *.scala set filetype=scala
au BufRead,BufNewFile *.tsx set filetype=typescript.tsx
au BufRead,BufNewFile *.jsx set filetype=typescript.jsx

augroup QfAutoCommands
  autocmd!

  " Auto-close quickfix window
  autocmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif
augroup END

let s:dein_path = expand('$XDG_CONFIG_HOME/dein')
if &compatible
  set nocompatible
endif
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state(s:dein_path)
  call dein#begin(s:dein_path)

  call dein#add('Shougo/dein.vim')
  call dein#add('tomasr/molokai')

  let s:toml_dir = expand('$XDG_CONFIG_HOME/nvim/')
  call dein#load_toml(s:toml_dir . 'plugins.toml', {'lazy': 0})

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

filetype plugin indent on
syntax enable

" set term=xterm-256color
let g:solarized_termcolors=256
syntax enable
set background=dark
autocmd colorscheme molokai highlight Visual ctermbg=8
colorscheme molokai

" auto close
let g:closetag_filenames = "*.html, *.xhtml, *.phtml, *.erb,*.jsx, *.php, *.tsx"
let g:closetag_xhtml_filenames = '*.xhtml, *.jsx, *.erb, *.php, *.tsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'

" vue
autocmd FileType vue syntax sync fromstart

" ALE lint
let g:ale_completion_enabled = 1
let g:lightline = {
  \'active': {
  \  'left': [
  \    ['mode', 'paste'],
  \    ['readonly', 'filename', 'modified', 'ale'],
  \  ]
  \},
  \'component_function': {
  \  'ale': 'ALEGetStatusLine'
  \}
\ }
let g:ale_sign_column_always = 1
let g:ale_statusline_format = ['Error%d', 'W%d', '']
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

let g:ale_linters = {
      \ 'html': [],
      \ 'go': ['gopls', 'golint', 'gometalinter']
      \ }

let g:ale_fixers = {
      \ 'javascript': ['prettier'],
      \ 'python': ['autopep8', 'isort'],
      \ 'php': ['php_cs_fixer', 'phpcbf'],
      \ 'scala': ['scalafmt'],
      \ 'rust': ['rustfmt'],
      \ 'go': ['gofmt']
      \ }
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_use_local_config = 1
let g:formatdef_scalafmt = "'scalafmt --stdin'"
let g:formatters_scala = ['scalafmt']
let g:ale_rustfmt_executable = 'rustfmt'
let g:ale_rust_cargo_use_check = 1
let g:ale_rust_cargo_check_tests = 1
let g:ale_rust_cargo_check_examples = 1

"Quickfixが残っている場合に閉じる
augroup QfAutoCommands
  autocmd!
        " Auto-close quickfix window
        autocmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif
augroup END


" setting vimfiler
let g:vimfiler_as_default_explorer = 2
let g:vimfiler_ignore_pattern = ['^\.git$', '^\.DS_Store$']
function! UniteFileCurrentDir()
  let s  = ':Unite file -start-insert -path='
  let s .= vimfiler#helper#_get_file_directory()
  execute s
endfunction

" vim-airline
let g:airline_theme = 'molokai'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'y', 'z']]
let g:airline_section_c = '%f%t'
let g:airline_section_x = '%{&filetype}'
let g:airline_section_z = '%3l:%2v %{airline#extensions#ale#get_warning()} %{airline#extensions#ale#get_error()}'
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#coc#enabled = 1
let airline#extensions#coc#error_symbol = 'E:'
let airline#extensions#coc#warning_symbol = 'W:'
let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'
let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

" setting ctrlp
let g:ctrlp_max_height    = 20
let g:ctrlp_user_command  = 'ag %s -l'
let g:ctrlp_working_path_mode = 'a'
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|pkg\|git\|vender\|Vender\|tmp\|\v\.(o|d|out|log|bin|gcno|gcda|pyc|retry|log|dist|out|.next)$'
let g:ctrlp_use_caching   = 0
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
    \ }
endif

" unite
" insert modeで開始
let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200

" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

nnoremap <silent> <Leader>p  :<C-u>CtrlP<CR>
nnoremap <silent> <Leader>g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent> <Leader>cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
nnoremap <silent> <Leader>r  :<C-u>UniteResume search-buffer<CR>
nnoremap <silent> <Leader>y :<C-u>Unite history/yank<CR>
nnoremap <silent> <Leader>b :<C-u>Unite buffer<CR>
nnoremap <silent> <Leader>f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> <Leader>r :<C-u>Unite -buffer-name=register register<CR>

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column --ignore=*.log'
  let g:unite_source_grep_recursive_opt = ''
endif

" vim test
nnoremap <silent> <Leader>t :TestFile<CR>

" Qfreplace
nnoremap <silent> <Leader>q :Qfreplace<CR>

" vim-altr
nnoremap <silent> <Leader>a <Plug>(altr-forward)

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" scala
let g:formatdef_scalafmt = "'scalafmt --stdin'"
let g:formatters_scala = ['scalafmt']

au BufRead,BufNewFile *.sbt set filetype=scala

" Remap keys for gotos coc.nvim
nmap <C-]> <Plug>(coc-definition)
nnoremap <C-[> <Plug>(coc-references)
let g:coc_global_extensions = [
  \ 'coc-diagnostic',
  \ 'coc-rls',
  \ 'coc-go',
  \ 'coc-phpls',
  \ 'coc-python',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-stylelint',
  \ 'coc-tailwindcss',
  \ 'coc-vetur',
  \ 'coc-json',
  \ 'coc-tsserver',
  \ 'coc-prettier',
  \ 'coc-eslint',
  \ ]

" operator-camelize
xmap tt <plug>(operator-camelize-toggle)
xmap tc <plug>(operator-camelize)
xmap ts <plug>(operator-decamelize)

let g:camelcasemotion_key = ','

let g:goimports_simplify = 1

if system('uname -a | grep Microsoft') != ""
  let g:clipboard = {
        \   'name': 'myClipboard',
        \   'copy': {
        \      '+': 'win32yank.exe -i',
        \      '*': 'win32yank.exe -i',
        \    },
        \   'paste': {
        \      '+': 'win32yank.exe -o',
        \      '*': 'win32yank.exe -o',
        \   },
        \   'cache_enabled': 1,
        \ }
endif

nnoremap <silent> <Leader>y :call emmet#expandAbbr(3,"")<CR>
