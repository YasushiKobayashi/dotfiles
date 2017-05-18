set term=xterm-256color
colorscheme molokai
syntax on
set autoindent
set expandtab
set modifiable
set tabstop=2
set shiftwidth=2
set cursorline
set number
set guifont=Inconsolata
set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double
set wildmenu
set history=5000


" alias
:command Vs vsplit
:command Tr NERDTree
:command Ni NeoBundleInstall

" imap
imap { {}<LEFT>
imap [ []<LEFT>
imap ( ()<LEFT>

" setting quickrun
let g:quickrun_config = get(g:, 'quickrun_config', {})
let s:eslint_path = system('PATH=$(npm bin):$PATH && which eslint')
let b:quickrun_eslint_path = substitute(s:eslint_path, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
let g:quickrun_config = {
\ '_': {
  \ 'runner' : 'vimproc',
  \ 'runner/vimproc/updatetime' : 60,
  \ 'outputter' : 'buffered',
  \ 'outputter/buffered/target' : 'message',
  \ 'outputter/buffer/close_on_empty' : 1,
  \ 'outputter/buffer/split'  : ':rightbelow 2sp',
\ },
\ 'javascript.jsx': {
  \ 'command'  : b:quickrun_eslint_path,
  \ 'cmdopt'   : '--config ~/.react/.eslintrc',
  \ 'exec'     : '%c %o %s',
  \ 'outputter': 'error',
  \ 'outputter/error/error'   : 'quickfix',
  \ 'outputter/quickfix/errorformat': '\ \ %l:%c\ \ error\ %m,%-G%.%#',
  \ 'outputter/quickfix/open_cmd': 'copen 1',
  \ },
\}

let g:quickrun_no_default_key_mappings = 1
nnoremap <Leader>r :ccl<CR>:write<CR>:QuickRun -mode n<CR>
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
let s:hook = {
  \ "name" : "face",
  \ "kind" : "hook",
  \ "is_success": 0,
  \ "config" : {
  \ "enable" : 1
  \ }
  \ }
function! s:hook.on_success(...)
  if(&ft=='javascript.jsx')
    let self.is_success = 1
  endif
endfunction
function! s:hook.on_exit(...)
  if self.is_success
    echo ":-)"
  endif
endfunction
call quickrun#module#register(s:hook, 1)
unlet s:hook
unlet s:eslint_path

" setting eslint
let g:syntastic_javascript_checkers=['eslint']
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0

" setting ctrlp
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

" setting lightline
set laststatus=2
set showmode
set showcmd
set ruler

" setting neobundle
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#min_keyword_length = 3
let g:neocomplete#enable_auto_delimiter = 1
let g:neocomplete#auto_completion_start_length = 1
inoremap <expr><BS> neocomplete#smart_close_popup()."<C-h>"
imap <expr><CR> neosnippet#expandable() ? "<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "<C-y>" : "<CR>"
imap <expr><TAB> pumvisible() ? "<C-n>" : neosnippet#jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<TAB>"



" others
autocmd BufWritePre * :%s/\s\+$//ge

" NeoBundle plugin
if 0 | endif

if &compatible
  set nocompatible               " Be iMproved
endif

set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle "Shougo/neosnippet"
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'fatih/vim-go'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'pmsorhaindo/syntastic-local-eslint.vim'
NeoBundle 'szw/vim-tags'
NeoBundle "ctrlpvim/ctrlp.vim"
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'tell-k/vim-browsereload-mac'
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'thinca/vim-quickrun'

call neobundle#end()
filetype plugin indent on
NeoBundleCheck
