if [ -f ~/.bashrc ] ; then
. ~/.bashrc
fi
eval "$(direnv hook bash)"

export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

eval "$(nodenv init -)"
export PATH="$HOME/.nodenv/bin:$PATH"

PYENV_ROOT=~/.pyenv
export PATH=$PATH:$PYENV_ROOT/bin
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

alias ll='ls -la'
alias ctags="`brew --prefix`/bin/ctags"

export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"


# mysetting
export DOCUMENT_ENV=develop

