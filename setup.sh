#!/usr/bin/env bash

# Symlink .config files and directories
cp -rsfi $HOME/.dotfiles/.config $HOME/

# Symlink scripts
cp -rsfi $HOME/.dotfiles/.local $HOME/

# Symlink bash
cp -rsfi $HOME/.dotfiles/.bash* $HOME/

# Symlink tmux
cp -rsfi $HOME/.dotfiles/.tmux $HOME/
cp -rsfi $HOME/.dotfiles/.tmux.conf $HOME/

