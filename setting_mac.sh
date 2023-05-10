#!/bin/sh
# install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


brew install wget anyenv zsh-completions tmux tmuxinator \
  zsh git neovim helm peco bat evans ghq hub htop jq octant saml2aws tig tor yarn awscli direnv


brew tap caskroom/cask
brew install --cask 1password/tap/1password-cli
brew cask install google-chrome firefox docker iterm2 1password 1password-cli visual-studio-code sequel-pro sequel-ace sublime-text fork maccy appcleaner \
  karabiner-elements discord alfred
