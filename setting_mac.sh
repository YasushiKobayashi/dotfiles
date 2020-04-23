#!/bin/sh
# install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


brew install wget anyenv zsh-completions tmux tmuxinator zsh git neovim

brew tap caskroom/cask
brew cask install google-chrome docker iterm2

wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator
