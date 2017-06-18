if [ -f ~/.bashrc ] ; then
. ~/.bashrc
fi
eval "$(direnv hook bash)"
export PATH=/usr/local/bin:$PATH
eval "$(rbenv init -)"
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
alias ll='ls -la'
alias ctags="`brew --prefix`/bin/ctags"
alias ctagsr="ctags -R --exclude=.git --exclude=node_modules --exclude=test --exclude=vender"

export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"


# mysetting
export DOCUMENT_ENV=develop

