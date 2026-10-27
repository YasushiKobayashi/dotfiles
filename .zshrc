if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  # git の diff-highlight。Cellar のバージョン直叩きは brew 呼び出しで 700ms 食うので glob で解決
  for _dh in /opt/homebrew/Cellar/git/*/share/git-core/contrib/diff-highlight(N); do
    export PATH="$_dh:$PATH"
  done
  unset _dh
fi
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/dotfiles/bin:$PATH
export SHELDON_CONFIG_FILE=$HOME/dotfiles/sheldon/plugins.toml
eval "$(sheldon source)"
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

alias ll='ls -la'
alias c='claude'
alias g='git'
alias gc='cd $(ghq root)/$(ghq list | peco)'
alias gho='gh browse -R $(ghq list | peco | cut -d "/" -f 2,3)'
alias pcat='bat $(ls | peco)'
alias d='docker'
alias dc='docker compose'
alias k='kubecolor'
alias mkdir='mkdir -p'
alias lerna='npx lerna'
alias t="tig status"
alias tf="terraform"
alias phpunit="./vendor/bin/phpunit"
# nvim-left を標準の nvim として使う
alias nvim='nvim-left'

function peco-history-selection() {
    BUFFER=`history -n 1 | tac  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^r' peco-history-selection

function peco-git-recent-pull-requests () {
    local selected_pr_number=$(gh pr list --limit 40 --search "sort:updated-desc" --json number,title,author --template '{{range .}}{{printf "#%-6v" .number}}  {{.title}} (by @{{.author.login}}){{"\n"}}{{end}}' | peco | sed -E 's/^#([0-9]+).*$/\1/')
    if [ -n "$selected_pr_number" ]; then
        BUFFER="gh pr checkout ${selected_pr_number}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-git-recent-pull-requests
alias gpc='peco-git-recent-pull-requests'


# nvim
export XDG_CONFIG_HOME="$HOME/dotfiles"
export NVIM_PYTHON_LOG_FILE=/tmp/log
export NVIM_NODE_LOG_FILE=/tmp/log
export NVIM_PYTHON_LOG_LEVEL=DEBUG
ensure_nvim_listen_address_dir() {
  local addr="${NVIM_LISTEN_ADDRESS:-}"
  local tmpdir="${TMPDIR%/}"
  if [[ -z "$addr" || "$addr" != /* ]]; then
    return 0
  fi
  if [[ -n "$tmpdir" && "$addr" == "$tmpdir/"* ]]; then
    addr="/tmp/${addr#$tmpdir/}"
    export NVIM_LISTEN_ADDRESS="$addr"
  fi
  mkdir -p "$(dirname "$addr")"
}

export CLOUDSDK_PYTHON=python3

export EXPANDED_CODE_SIGN_IDENTITY=
export EXPANDED_CODE_SIGN_IDENTITY_NAME=
export EXPANDED_PROVISIONING_PROFILE=
export NUXT_TELEMETRY_DISABLED=1
export VISUAL=nvim
export EDITOR=nvim

case ${OSTYPE} in
  darwin*)
  alias tac="tail -r"
    # ここに Mac 向けの設定
    alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
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
  ensure_nvim_listen_address_dir
}

# anyenv init の結果をキャッシュして読む。起動毎の rehash は重い(~150ms)ので --no-rehash。
# npm -g などで新しいコマンドを入れた時は手動で `nodenv rehash` / `pyenv rehash` する。
# env を追加/削除したら ~/.anyenv/envs の mtime が変わり自動で再生成される。
_anyenv_cache=${XDG_CACHE_HOME:-$HOME/.cache}/anyenv-init.zsh
if (( $+commands[anyenv] )); then
  if [[ ! -s $_anyenv_cache || ~/.anyenv/envs -nt $_anyenv_cache ]]; then
    mkdir -p ${_anyenv_cache:h}
    # XDG_CONFIG_HOME=~/dotfiles のままだと定義ディレクトリが見つからず env が 1 つも出力されない
    ANYENV_DEFINITION_ROOT=${ANYENV_DEFINITION_ROOT:-$HOME/.config/anyenv/anyenv-install} \
      anyenv init - --no-rehash zsh >| $_anyenv_cache
  fi
  source $_anyenv_cache
fi
unset _anyenv_cache

export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
export AQUA_GLOBAL_CONFIG=${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/dotfiles}/aqua.yaml

source ~/dotfiles/comp/.mise-completion.zsh

# gh completion (aqua で入れた gh と op プラグイン alias の両方が読み込まれた後に実行)
# 毎回 gh を起動すると ~110ms かかるのでキャッシュ。aqua.yaml 更新(= gh のバージョン変更)で再生成
if (( $+commands[gh] )); then
  _gh_comp_cache=${XDG_CACHE_HOME:-$HOME/.cache}/gh-completion.zsh
  if [[ ! -s $_gh_comp_cache || ~/dotfiles/aqua.yaml -nt $_gh_comp_cache ]]; then
    mkdir -p ${_gh_comp_cache:h}
    gh completion -s zsh >| $_gh_comp_cache
  fi
  source $_gh_comp_cache
  unset _gh_comp_cache
fi
source ~/dotfiles/gh/plugins.sh

. "$HOME/.local/bin/env"

# pnpm
export PNPM_HOME="/Users/yasushi.kobayashi/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# gw shell integration
eval "$(gw shell-integration --show-script --shell=zsh)"
