# My Dotfiles

This repository contains the configurations for tools that I use on a daily basis.

## Requirements
Before setting up a new dev environment make sure the following is present:
- `git`
- `curl`

# Instructions for quickly setting up configurations on a new machine

The recommended setup is to run the init script from git:

```bash
curl -Lks github.com/rogvid/dotfiles/setup.sh | /bin/bash
```

When this is done, install the tools below following their respective guides.

## Tools
### CLI 
- oh-my-zsh with
- batcat - https://github.com/sharkdp/bat
- gdu
- direnv
- asdf
- btm
- git
- ripgrep
- bottom - cargo install bottom
### Terminal
### Applications
- minio: https://www.digitalocean.com/community/tutorials/how-to-set-up-minio-object-storage-server-in-standalone-mode-on-ubuntu-20-04
- slack
- netron
- docker + compose
- kubectl
- aws cli
- nvim
- nix cli
- tmux
- dive 
### Languages
- micromamba

```bash
curl micro.mamba.pm/install.sh | bash
```

- Rust: install from rust-lang.org

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

- node: Use option #3 from https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04

## Configuring Applications

### Neovim

#### Requirements
- Nerd Fonts
- Neovim
- Tree-sitter CLI
- ripgrep
- gdu
- bottom
- Python
- Node

#### User Installation
Start by installing the latest stable neovim version from https://github.com/neovim/neovim/releases
Once installed run the following commands:

```bash
git clone https://github.com/AstroNvim/AsroNvm ~/.config/nvim
nvim  --headless -c 'autocmd User PackerComplete quitall'
```
