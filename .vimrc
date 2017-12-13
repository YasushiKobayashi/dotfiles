syntax on
set synmaxcol=200
set autoindent
set expandtab
set modifiable
set smartindent
set nobackup
set directory=~/.vim/tmp
set clipboard=unnamed,autoselect
" set clipboard+=unnamedplus
set undodir=D:/home/koron/var/vim/undo
set tabstop=2
set shiftwidth=2
set nocursorline
set number
set guifont=Inconsolata
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double
set wildmenu
set history=5000
set whichwrap=b,s,<,>,[,]
set showtabline=2
scriptencoding utf-8
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return>

" set
                           \ 'passive_filetypes': [] }
" alias
:command Ni NeoBundleInstall

" imap
imap { {}<LEFT>
imap [ []<LEFT>
imap ( ()<LEFT>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

" setting ctrlp
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|pkg\|git\|vender\|Vender\|tmp\|\v\.(o|d|out|log|bin|gcno|gcda|pyc|retry|log)$'
let g:ctrlp_user_command = 'ag %s -l'
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|pkg\|git\|vender\|Vender\|tmp\|\v\.(o|d|out|log|bin|gcno|gcda|pyc|retry|log)$'

" setting neobundle
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#min_keyword_length = 3
let g:neocomplete#enable_auto_delimiter = 1
let g:neocomplete#auto_completion_start_length = 1
imap <expr><CR> neosnippet#expandable() ? "<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "<C-y>" : "<CR>"
imap <expr><TAB> pumvisible() ? "<C-n>" : neosnippet#jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<TAB>"

" setting keymap
:map <C-t> <C-p>

" ctags
let g:auto_ctags = 1
nnoremap <C-h> :vsp<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap <C-k> :split<CR> :exe("tjump ".expand('<cword>'))<CR>

" 起動時設定
au BufRead,BufNewFile *.scss set filetype=css

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

set statusline=%{ALEGetStatusLine()}
nmap <silent> <C-w>j <Plug>(ale_next_wrap)
nmap <silent> <C-w>k <Plug>(ale_previous_wrap)

" multiple-cursors
" Called once right before you start selecting multiple cursors
function! Multiple_cursors_before()
  if exists(':NeoCompleteLock')==2
    exe 'NeoCompleteLock'
  endif
endfunction

" Called once only when the multiple selection is canceled (default <Esc>)
function! Multiple_cursors_after()
  if exists(':NeoCompleteUnlock')==2
    exe 'NeoCompleteUnlock'
  endif
endfunction

""" unite.vim
" 入力モードで開始する
" let g:unite_enable_start_insert=1
" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
" 常用セット
nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
" 全部乗せ
nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>
" ウィンドウを分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
" ウィンドウを縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_actio;('vsplit')
" ESCキーを2回押すと終了する
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> q
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>q
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


" setting vimfiler
let g:vimfiler_as_default_explorer = 1
function! UniteFileCurrentDir()
  let s  = ':Unite file -start-insert -path='
  let s .= vimfiler#helper#_get_file_directory()

  execute s
endfunction

autocmd FileType vimfiler
      \ nnoremap <buffer><silent>/
      \ :call UniteFileCurrentDir() <CR>


" golang
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1

" markdown
au BufRead,BufNewFile *.md set filetype=markdown
let g:previm_open_cmd = 'open -a Firefox'

" others
autocmd BufWritePre * :%s/\s\+$//ge
let g:nerdtree_tabs_open_on_console_startup=1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


" NeoBundle plugin
if 0 | endif

if &compatible
  set nocompatibl
endif

set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'tomasr/molokai'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle "Shougo/neosnippet.vim"
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'fatih/vim-go'
NeoBundle 'w0rp/ale'
NeoBundle 'szw/vim-tags'
NeoBundle 'soramugi/auto-ctags.vim'
NeoBundle "ctrlpvim/ctrlp.vim"
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'surround.vim'
NeoBundle 'Townk/vim-autoclose'
NeoBundle 'othree/yajs.vim'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'gabrielelana/vim-markdown'
NeoBundle 'Shougo/vimfiler'
NeoBundle 'maxmellon/vim-jsx-pretty'
NeoBundle 'rust-lang/rust.vim'
NeoBundle 'osyo-manga/vim-over'

call neobundle#end()
filetype plugin indent on
NeoBundleCheck

" set term=xterm-256color
autocmd colorscheme molokai highlight Visual ctermbg=8
colorscheme molokai

