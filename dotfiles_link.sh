#!/bin/sh
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.vim/autoload ~/.vim/autoload
ln -sf ~/dotfiles/.vim/colors ~/.vim/colors
ln -sf ~/dotfiles/.bash_profile ~/.bash_profile
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/tmuxinator ~/.config/tmuxinator
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.zpreztorc ~/.zpreztorc
ln -sf ~/dotfiles/.editorconfig ~/.editorconfig
ln -sf ~/dotfiles/.textlintrc ~/.textlintrc
ln -sf ~/dotfiles/karabiner.json ~/.config/karabiner/karabiner.json
ln -sf ~/dotfiles/efm-langserver/config.yaml ~/.config/efm-langserver/config.yaml
mkdir -p ~/.local/bin
ln -sf ~/dotfiles/bin/open_in_nvim_left ~/.local/bin/open_in_nvim_left
ln -sf ~/dotfiles/bin/nvim-left ~/.local/bin/nvim-left
ln -sf ~/dotfiles/bin/tmux_pick_path ~/.local/bin/tmux_pick_path

ln -sf ~/dotfiles/.mac_gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.linux_gitconfig ~/.gitconfig

ln -sf ~/dotfiles/.stCommitMsg ~/.stCommitMsg
ln -sf ~/dotfiles/.gitignore_global ~/.gitignore_global
ln -sf ~/dotfiles/.agignore ~/.agignore
ln -sf ~/dotfiles/.tigrc ~/.tigrc
ln -sf ~/dotfiles/.php_cs.dist ~/.php_cs.dist
ln -sf ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/nvim/plugins.toml ~/.config/nvim/plugins.toml
ln -sf ~/dotfiles/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
ln -sf ~/dotfiles/nvim/sonictemplate ~/.config/nvim/sonictemplate

ln -s ~/dotfiles/claude/.mcp.json ~/.mcp.json
ln -s ~/dotfiles/claude/settings.json ~/.claude/settings.json

ln -s ~/dotfiles/codex/AGENTS.md ~/.codex/AGENTS.md
