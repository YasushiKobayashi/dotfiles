#!/bin/sh
cd ~/.vim/bundle/jedi-vim && git submodule update --init
mkdir -p ~/.config/nvim/
ln -snfv ~/.vim ~/.config/nvim/
ln -snfv ~/.vimrc ~/.config/nvim/init.vim
