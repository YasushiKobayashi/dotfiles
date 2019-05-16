
export LANG=ja_JP.UTF-8


# 色を使用出来るようにする
autoload -Uz colors
colors

########################################
# 補完
# 補完機能を有効にする
autoload -Uz compinit
compinit

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

########################################
# オプション
# 日本語ファイル名を表示可能にする
setopt print_eight_bit
# ディレクトリ名だけでcdする
setopt auto_cd

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups


##############################
# package setting
eval "$(direnv hook zsh)"
alias ctags="`brew --prefix`/bin/ctags"

export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

export PATH="$PATH:$HOME/.composer/vendor/bin"

export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH=$GOENV_ROOT/bin:$PATH

alias ll='ls -la'
alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
alias pcat='cat $(ls | peco)'
alias dc='docker-compose'
alias bs='BrowserStackLocal --key $BS_KEY'

# completions
fpath=(/usr/local/share/zsh-completions $fpath)

# nvim
export XDG_CONFIG_HOME=$HOME/.config
export NVIM_PYTHON_LOG_FILE=/tmp/log
export NVIM_PYTHON_LOG_LEVEL=DEBUG

# hub https://github.com/github/hub
eval "$(hub alias -s)"

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


export CLOUDSDK_PYTHON_SITEPACKAGES=1
export CLOUDSDK_PYTHON=$HOME/.pyenv/versions/2.7.11/bin/python

# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then source $HOME/google-cloud-sdk/path.zsh.inc; fi

# The next line enables shell command completion for gcloud.
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then source $HOME/google-cloud-sdk/completion.zsh.inc; fi
export PATH="/usr/local/sbin:$PATH"

export EXPANDED_CODE_SIGN_IDENTITY=
export EXPANDED_CODE_SIGN_IDENTITY_NAME=
export EXPANDED_PROVISIONING_PROFILE=
export PATH="/usr/local/opt/bison/bin:$PATH"
