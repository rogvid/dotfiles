#!/usr/bin/env bash

if ! command -v stow &> /dev/null; then
    echo "stow could not be found, please install it first."
    exit 1
fi

if [ ! -d "$HOME/.dotfiles" ]; then
	echo "No dotfiles directory found. Cloning dotfiles repository..."
	# Clone my dotfiles repository
	git clone https://github.com/rogvid/.dotfiles.git $HOME/.dotfiles
	#
	# Since I make use of tmux I want to clone the tpm plugins folder
	# to set up tmux
	# if [ ! -d "$HOME/.tmux/plugins" ]; then mkdir $HOME/.tmux/plugins; fi
	# if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm; fi

	# Ensure that the config directory exists
	if [ ! -d "$HOME/.config" ]; then mkdir $HOME/.config; fi

	# Stow everything
	stow --verbose --restow --target=$HOME */
else
	echo "Dotfiles directory found. Terminating initialization..."
fi

if ! command -v nix-env &> /dev/null; then
    echo "Please make sure nix is installed"
    exit 1
fi

# all: stow --verbose --target=$$HOME --restow */
# delete: stow --verbose --target=$$HOME --delete */
# Install nix packages
nix-env -iA nixpkgs.myPackages

