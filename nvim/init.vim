syntax on
set synmaxcol=200
set autoindent
set expandtab
set modifiable
set smartindent
set nobackup
set directory=~/.vim/tmp
set clipboard+=unnamedplus
set undodir=D:/home/koron/var/vim/undo
set tabstop=2
set shiftwidth=2
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
set spell
set spelllang=en_us
set ttimeout
set ttimeoutlen=50
scriptencoding utf-8

" imap
imap { {}<LEFT>
imap [ []<LEFT>
imap ( ()<LEFT>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

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

" 起動時設定
au BufRead,BufNewFile *.scss set filetype=css

let s:dein_path = expand('~/.vim/dein')
if &compatible
  set nocompatible
endif
set runtimepath+=$XDG_CONFIG_HOME/nvim/repos/github.com/Shougo/dein.vim

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

"Python3 support
let g:python3_host_prog = expand('$HOME') . '/.pyenv/shims/python'
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_profile = 1

" multiple-cursors
" Called once right before you start selecting multiple cursors
function! Multiple_cursors_before()
  let g:deoplete#disable_auto_complete = 1
endfunction
function! Multiple_cursors_after()
  let g:deoplete#disable_auto_complete = 0
endfunction

" setting ctrlp
let g:ctrlp_max_height          = 20
let g:ctrlp_user_command = 'ag %s -l'
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|pkg\|git\|vender\|Vender\|tmp\|\v\.(o|d|out|log|bin|gcno|gcda|pyc|retry|log)$'
let g:ctrlp_use_caching = 0
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor

    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
    \ }
endif

" ctags
let g:auto_ctags = 1
nnoremap <C-h> :vsp<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap <C-k> :split<CR> :exe("tjump ".expand('<cword>'))<CR>

" ALE lint
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

" setting vimfiler
let g:vimfiler_as_default_explorer = 1
function! UniteFileCurrentDir()
  let s  = ':Unite file -start-insert -path='
  let s .= vimfiler#helper#_get_file_directory()
  execute s
endfunction

" golang
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1

" eslint pretter
let g:neoformat_javascript_prettiereslint = {
      \ 'exe': './node_modules/.bin/prettier-eslint',
      \ 'args': ['--stdin'],
      \ 'stdin': 1,
      \ }
augroup fmt
  autocmd!
  autocmd BufWritePre * Neoformat
augroup END
let g:neoformat_enabled_javascript = ['prettiereslint']

" vim-over
nnoremap <C-o> :OverCommandLine<CR>
