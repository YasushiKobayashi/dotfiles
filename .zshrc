
export LANG=ja_JP.UTF-8

# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history

# メモリに保存される履歴の件数
export HISTSIZE=1000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000

# 重複を記録しない
setopt hist_ignore_dups

# 開始と終了を記録
setopt EXTENDED_HISTORY

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

export GOENV_DISABLE_GOPATH=1
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH=$GOENV_ROOT/bin:$PATH

export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

export PATH="$PATH:$HOME/.composer/vendor/bin"

export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'

alias ll='ls -la'
alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
alias pcat='cat $(ls | peco)'
alias dc='docker-compose'
alias mkdir='mkdir -p'


peco-select-history() {
    BUFFER=$(history 1 | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
    CURSOR=${#BUFFER}
    zle reset-prompt
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# completions
fpath=(/usr/local/share/zsh-completions $fpath)

# nvim
export XDG_CONFIG_HOME=$HOME/.config
export NVIM_PYTHON_LOG_FILE=/tmp/log
export NVIM_NODE_LOG_FILE=/tmp/log
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

function chpwd() { echo -ne "\033]0;$(pwd | rev | awk -F \/ '{print "/"$1"/"$2}'| rev)\007"}
alias top='tab-color 134 200 0; top; tab-reset'

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/yasushi.kobayashi/.anyenv/envs/nodenv/versions/10.15.0/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/yasushi.kobayashi/.anyenv/envs/nodenv/versions/10.15.0/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/yasushi.kobayashi/.anyenv/envs/nodenv/versions/10.15.0/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/yasushi.kobayashi/.anyenv/envs/nodenv/versions/10.15.0/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /Users/yasushi.kobayashi/.anyenv/envs/nodenv/versions/10.15.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . /Users/yasushi.kobayashi/.anyenv/envs/nodenv/versions/10.15.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh
