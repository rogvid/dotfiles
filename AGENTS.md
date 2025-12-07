# Agent Guidelines for Dotfiles Repository

## Build/Test/Deploy Commands
- **Deploy**: `stow --verbose --restow --target=$HOME */` (stow all configurations)
- **Setup**: `./setup.sh` (initialize dotfiles and dependencies)
- **Test**: No automated tests - manual verification by sourcing config files
- **Lint**: `stylua` for Lua files (nvim config), `shellcheck` for shell scripts

## Code Style & Conventions

### Shell Scripts (.sh, .bash, .zsh)
- Use `#!/usr/bin/env bash` shebang with `set -euo pipefail`
- Quote variables: `"${variable}"` not `$variable`
- Use descriptive function names: `ensure_local_bin()`, `check_installed()`
- Follow existing naming: lowercase with underscores

### Lua (Neovim Config)
- Use snake_case for variables and functions
- Organize plugins in separate files under `lua/plugins/`
- Use vim.api for autocmds, vim.keymap.set for keymaps
- Comment with `--` for single line, block comments for complex logic

### General
- Maintain existing file structure and naming patterns
- Use descriptive variable names, avoid abbreviations
- Follow existing indentation (2 spaces for Lua, varies for shell)
- No trailing whitespace, end files with newline