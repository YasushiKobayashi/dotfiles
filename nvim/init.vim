let g:python_host_prog = $PYENV_ROOT.'/shims/python'
let g:python3_host_prog = $PYENV_ROOT.'/shims/python'
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
set clipboard&
set clipboard^=unnamedplus
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
set list
set listchars=tab:»-,trail:-,nbsp:%,eol:↲
set ignorecase
set smartcase
set wrapscan
set incsearch
set inccommand=split
set mouse=
set ttimeoutlen=0
set notermguicolors

" imap
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

tnoremap <silent> <ESC> <C-\><C-n>

nnoremap x "_x
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
let g:ale_fixers = {
      \ 'rust': ['rustfmt'],
      \ }
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1
let g:ale_rustfmt_executable = 'rustfmt'

"Quickfixが残っている場合に閉じる
augroup QfAutoCommands
  autocmd!
  " Auto-close quickfix window
  autocmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif
augroup END

" vim-airline
let g:airline_theme = 'molokai'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'y', 'z']]
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#coc#enabled = 1
let airline#extensions#coc#error_symbol = 'E:'
let airline#extensions#coc#warning_symbol = 'W:'
let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'
let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

" unite
" insert modeで開始
let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200

" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

nnoremap <silent> <Leader>g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent> <Leader>r  :<C-u>UniteResume search-buffer<CR>
nnoremap <silent> <Leader>b :<C-u>Unite buffer<CR>

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column --ignore=*.log'
  let g:unite_source_grep_recursive_opt = ''
endif

" Qfreplace
nnoremap <silent> <Leader>q :Qfreplace<CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" Remap keys for gotos coc.nvim
nmap <C-]> <Plug>(coc-definition)
nmap <C-j> <Plug>(coc-definition)
nnoremap <C-/> <Plug>(coc-references)
let g:coc_global_extensions = [
  \ 'coc-lists',
  \ 'coc-pairs',
  \ 'coc-diagnostic',
  \ 'coc-rls',
  \ 'coc-go',
  \ 'coc-phpls',
  \ 'coc-php-cs-fixer',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-stylelint',
  \ 'coc-tailwindcss',
  \ 'coc-json',
  \ 'coc-tsserver',
  \ 'coc-prettier',
  \ 'coc-eslint',
  \ 'coc-prisma',
  \ 'coc-graphql',
  \ 'coc-vetur',
  \ 'coc-sql',
  \ 'coc-protobuf',
  \ ]
  " \ 'coc-python',

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" GitHub Copilot
let g:copilot_no_tab_map = v:true
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
imap <C-]> <Plug>(copilot-next)
imap <C-[> <Plug>(copilot-previous)

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" operator-camelize
xmap tt <plug>(operator-camelize-toggle)
xmap tc <plug>(operator-camelize)
xmap ts <plug>(operator-decamelize)

nnoremap <silent> <Leader>p :CocList files<CR>
nnoremap <silent> <Leader>f :let @+=expand('%:p')<CR>:echo 'Copied: ' . expand('%:p')<CR>


let g:camelcasemotion_key = ','

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
let g:tagalong_filetypes = ['html', 'php', 'javascript', 'javascript.jsx', 'jsx', 'typescript', 'typescript.tsx', 'tsx', 'vue', 'javascript.vue', 'typescript.vue']

nnoremap <silent> <Leader>c :G commit<CR>
