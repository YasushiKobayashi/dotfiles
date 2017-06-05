set term=xterm-256color
autocmd colorscheme molokai highlight Visual ctermbg=8
colorscheme molokai
syntax on
set autoindent
set expandtab
set modifiable
set smartindent
set nobackup
set clipboard=unnamed,autoselect
set tabstop=2
set shiftwidth=2
set cursorline
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

" set
                           \ 'passive_filetypes': [] }
" alias
:command Ni NeoBundleInstall

" imap
imap { {}<LEFT>
imap [ []<LEFT>
imap ( ()<LEFT>

" setting ctrlp
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|vender'

" setting neobundle
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#min_keyword_length = 3
let g:neocomplete#enable_auto_delimiter = 1
let g:neocomplete#auto_completion_start_length = 1
inoremap <expr><BS> neocomplete#smart_close_popup()."<C-h>"
imap <expr><CR> neosnippet#expandable() ? "<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "<C-y>" : "<CR>"
imap <expr><TAB> pumvisible() ? "<C-n>" : neosnippet#jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<TAB>"

" setting keymap
:map <C-t> <C-p>

" setting NERDTree
let NERDTreeShowHidden = 1
nnoremap <silent><C-e> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$', '\.css$', '\.DS_Store$']

" vim-tags
au BufNewFile,BufRead *.php let g:vim_tags_project_tags_command = "ctags --languages=php -f ~/php.tags `pwd` 2>/dev/null &"

" others
autocmd BufWritePre * :%s/\s\+$//ge
nnoremap <silent><C-\> :NERDTreeToggle<CR>
let g:nerdtree_tabs_open_on_console_startup=1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" 起動時設定
autocmd VimEnter * execute 'NERDTree'
au BufRead,BufNewFile *.scss set filetype=css

set guifont=<FONT_NAME>:h<FONT_SIZE>
set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Plus\ Nerd\ File\ Types:h11
let g:lightline = {
      \ 'component_function': {
      \   'filetype': 'MyFiletype',
      \   'fileformat': 'MyFileformat',
      \ }
      \ }

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

" Syntasticの設定
" Javascript用. 構文エラーチェックにESLintを使用
let g:syntastic_javascript_checkers=['eslint']
" 構文エラー行に「>>」を表示
let g:syntastic_enable_signs = 1
" 他のVimプラグインと競合するのを防ぐ
let g:syntastic_always_populate_loc_list = 0
" 構文エラーリストを非表示
let g:syntastic_auto_loc_list = 1
" ファイルを開いた時に構文エラーチェックを実行する
let g:syntastic_check_on_open = 1
" 「:wq」で終了する時も構文エラーチェックする
let g:syntastic_check_on_wq = 1


" jsdoc
let g:jsdoc_default_mapping = 0
nnoremap <silent> <C-J> :JsDoc<CR>

" Unite
NeoBundle 'Shougo/unite.vim'
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
nnoremap <silent> ,uy :<C-u>Unite history/yank<CR>
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> ,uu :<C-u>Unite file_mru buffer<CR>

" NeoBundle plugin
if 0 | endif

if &compatible
  set nocompatibl
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
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'surround.vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'heavenshell/vim-jsdoc'
NeoBundle 'PDV--phpDocumentor-for-Vim'
NeoBundle 'moll/vim-node'
NeoBundle 'Townk/vim-autoclose'
NeoBundle 'PDV--phpDocumentor-for-Vim'
NeoBundle 'othree/yajs.vim'
NeoBundle 'maxmellon/vim-jsx-pretty'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'ryanoasis/vim-devicons'
NeoBundle 'tiagofumo/vim-nerdtree-syntax-highlight'
NeoBundle 'mattn/vim-terminal'
NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'jistr/vim-nerdtree-tabs'
NeoBundle 'Shougo/unite.vim'


call neobundle#end()
filetype plugin indent on
NeoBundleCheck
