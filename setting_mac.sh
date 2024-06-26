#!/bin/sh
# install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


brew install wget anyenv zsh-completions tmux tmuxinator \
  neovim htop octant tig tor yarn hub


brew tap caskroom/cask
brew install --cask 1password/tap/1password-cli
brew install --cask google-chrome firefox docker iterm2 1password 1password-cli visual-studio-code sequel-pro sequel-ace sublime-text fork maccy appcleaner \
  karabiner-elements discord alfred \
  table-tool medis obsa elgato-game-capture-hd deepl \
  zoom dropbox imageoptim figma miro mysqlworkbench
