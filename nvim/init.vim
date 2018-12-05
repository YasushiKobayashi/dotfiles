let g:python3_host_prog = expand('$HOME') . '/.pyenv/versions/3.6.0/bin/python'

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

nnoremap tc :s/_\(.\)/\u\1/g<CR>;
autocmd InsertLeave * set nopaste
autocmd QuickFixCmdPost vimgrep cwindow
autocmd QuickFixCmdPost *grep* cwindow

let mapleader = "\<Space>"

" 起動時設定
au BufRead,BufNewFile *.scss set filetype=css
au BufRead,BufNewFile *.scala  set filetype=scala

let s:dein_path = expand('~/.vim/dein')
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

"Python3 support
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_profile = 1

let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
let g:deoplete#ignore_sources.php = ['omni']

" auto close
let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.erb,*.jsx, *.php"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.erb, *.php'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'

" js import
nnoremap <C-i> :ImportJSFix<CR>

" vue
autocmd FileType vue syntax sync fromstart

" setting ctrlp
let g:ctrlp_max_height    = 20
let g:ctrlp_user_command  = 'ag %s -l'
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|pkg\|git\|vender\|Vender\|tmp\|\v\.(o|d|out|log|bin|gcno|gcda|pyc|retry|log)$'
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

" ctags
nnoremap <C-]> g<C-]>
nnoremap <C-s> :vsp<CR> :exe("tjump ".expand('<cword>'))<CR>
" nnoremap <C-a> :split<CR> :exe("tjump ".expand('<cword>'))<CR>


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

let g:ale_linters = {
      \ 'html': [],
      \ 'css': ['stylelint'],
      \ 'javascript': ['eslint', 'stylelint'],
      \ 'vue': ['eslint', 'stylelint'],
      \ 'typescript': ['tslint', 'stylelint'],
      \ 'swift': ['swiftlint'],
      \ 'php': ['phpcs'],
      \ }

let g:ale_fixers = {
      \ 'javascript': ['prettier_eslint'],
      \ 'typescript': ['prettier'],
      \ 'vue': ['prettier'],
      \ 'css': ['prettier_eslint'],
      \ 'scss': ['prettier_eslint'],
      \ 'python': ['autopep8', 'isort'],
      \ 'php': ['php_cs_fixer'],
      \ }
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_use_local_config = 1
let g:ale_typescript_tslint_config_path = 'tslint.yml'
let g:ale_php_phpcs_standard = 'PSR2'

" jsx syntax
let g:tigris#enabled = 1
let g:tigris#on_the_fly_enabled = 1
let g:tigris#delay = 300
let g:vim_jsx_pretty_enable_jsx_highlight = 1

" setting typescript
let g:tsuquyomi_completion_detail = 1
let g:syntastic_typescript_checkers = ['tsuquyomi']


" setting vimfiler
let g:vimfiler_as_default_explorer = 2
function! UniteFileCurrentDir()
  let s  = ':Unite file -start-insert -path='
  let s .= vimfiler#helper#_get_file_directory()
  execute s
endfunction

" golang
let g:syntastic_go_checkers = ['go', 'golint', 'govet']
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1

" vim-airline
let g:airline_theme = 'wombat'
set laststatus=2
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'y', 'z']]
let g:airline_section_c = '%t'
let g:airline_section_x = '%{&filetype}'
let g:airline_section_z = '%3l:%2v %{airline#extensions#ale#get_warning()} %{airline#extensions#ale#get_error()}'
let g:airline#extensions#ale#error_symbol = ' '
let g:airline#extensions#ale#warning_symbol = ' '
let g:airline#extensions#default#section_truncate_width = {}
let g:airline#extensions#whitespace#enabled = 1

" unite
" insert modeで開始
let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1


nnoremap <silent> <Leader>g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent> <Leader>cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
nnoremap <silent> <Leader>r  :<C-u>UniteResume search-buffer<CR>
nnoremap <silent> <Leader>y :<C-u>Unite history/yank<CR>
nnoremap <silent> <Leader>b :<C-u>Unite buffer<CR>
nnoremap <silent> <Leader>f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> <Leader>r :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> <Leader>uu :<C-u>Unite file_mru buffer<CR>

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

" swift
autocmd FileType swift imap <buffer> <C-]> <Plug>(deoplete_swift_jump_to_placeholder)
let g:deoplete#sources#swift#daemon_autostart = 1

" twitvim
let twitvim_browser_cmd = 'open' " for Mac
let twitvim_force_ssl = 1
let twitvim_enable_python =1
let twitvim_count = 40

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
