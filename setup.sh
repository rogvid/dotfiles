#!/usr/bin/env bash

# Symlink .config files and directories
cp -rsi $HOME/.dotfiles/.config $HOME/

# Symlink scripts
cp -rsi $HOME/.dotfiles/.local $HOME/

# Symlink bash
cp -rsi $HOME/.dotfiles/.bash* $HOME/

# Symlink tmux
cp -rsi $HOME/.dotfiles/.tmux $HOME/
cp -rsi $HOME/.dotfiles/.tmux.conf $HOME/

