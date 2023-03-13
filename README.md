# Instructions for quickly setting a new machine
Having cloned this repository you can run `setup.sh` to create symlinks where config files are usually placed. The setup.sh runs `cp -rsfi` on a variety of files and folders, so it will ask whether the file should be overwritten if it exists.

## First steps
The first steps after having set up a new machine is to ensure everything is up to date, and we have the necessary libraries

```bash
sudo apt-get update
sudo apt-get upgrade
```

Some things, such as build-essentials and gcc are almost always necessary for my use-cases so make sure they are installed

```bash
sudo apt-get install build-essentials
sudo apt-get install gcc
```

When this is done, install the tools below following their respective guides.

## Tools
### CLI 
- oh-my-posh with
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
