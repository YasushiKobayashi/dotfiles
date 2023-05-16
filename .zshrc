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
setopt inc_append_history
setopt share_history
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
export COMPOSER_PROCESS_TIMEOUT=1600
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

export PATH=/usr/local/bin:$PATH
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
export AQUA_GLOBAL_CONFIG=${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/dotfiles}/aqua.yaml

alias ll='ls -la'
alias g='git'
alias gc='cd $(ghq root)/$(ghq list | peco)'
alias gho='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
alias pcat='bat $(ls | peco)'
alias d='docker'
alias dc='docker-compose'
alias k='kubecolor'
alias mkdir='mkdir -p'
alias lerna='npx lerna'
alias t="tig status"
alias tf="terraform"
alias phpunit="./vendor/bin/phpunit"

function peco-history-selection() {
    BUFFER=`history -n 1 | tac  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^r' peco-history-selection

function peco-git-recent-pull-requests () {
    local selected_pr_number=$(hub pr list --limit 40 --sort updated --format "%pC%>(8)%i%Creset  %t (by @%au)%n" | peco | sed -r 's/^ +#([0-9]+).*$/\1/')
    if [ -n "$selected_pr_number" ]; then
        BUFFER="hub pr checkout ${selected_pr_number}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-git-recent-pull-requests
alias gpc='peco-git-recent-pull-requests'

# completions
fpath=(/usr/local/share/zsh-completions $fpath)
fpath=($(brew --prefix)/share/zsh-completions $fpath)
fpath=(~/.zsh/completion $fpath)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload -U compinit
compinit -u

# nvim
export XDG_CONFIG_HOME=$HOME/.config
export NVIM_PYTHON_LOG_FILE=/tmp/log
export NVIM_NODE_LOG_FILE=/tmp/log
export NVIM_PYTHON_LOG_LEVEL=DEBUG

# hub https://github.com/github/hub
eval "$(hub alias -s)"
eval "$(gh completion -s zsh)"

export CLOUDSDK_PYTHON=python3

export EXPANDED_CODE_SIGN_IDENTITY=
export EXPANDED_CODE_SIGN_IDENTITY_NAME=
export EXPANDED_PROVISIONING_PROFILE=
export PATH="/usr/local/opt/bison/bin:$PATH"
export NUXT_TELEMETRY_DISABLED=1
export VISUAL=nvim
export EDITOR=nvim

case ${OSTYPE} in
  darwin*)
  alias tac="tail -r"
    # ここに Mac 向けの設定
    ;;
  linux*)
    # ここに Linux 向けの設定
    ;;
esac

function chpwd() { echo -ne "\033]0;$(pwd | rev | awk -F \/ '{print "/"$1"/"$2}'| rev)\007"}
alias top='tab-color 134 200 0; top; tab-reset'

function precmd() {
  if [ ! -z $TMUX ]; then
    tmux refresh-client -S
  fi
}

export PATH="$HOME/.anyenv/bin:$PATH"
# eval "$(anyenv init -)"
# eval "$(pyenv init --path)"
# anyenv init - --no-rehash > ~/.anyenv-rc.sh
if [ -f ~/.anyenv-rc.sh ]; then
    source ~/.anyenv-rc.sh
fi

export PATH="$PATH:$HOME/.composer/vendor/bin"
export OMPOSER_MEMORY_LIMIT=-1

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yasushi.kobayashi/Desktop/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yasushi.kobayashi/Desktop/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yasushi.kobayashi/Desktop/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yasushi.kobayashi/Desktop/google-cloud-sdk/completion.zsh.inc'; fi
source ~/.config/op/plugins.sh
