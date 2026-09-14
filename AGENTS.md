# Agent Guidelines for Dotfiles Repository

## Build/Test/Deploy Commands
- **Deploy**: `mise bootstrap` (tools, packages, services and every `[dotfiles]` symlink)
- **Check for drift**: `mise run drift` (non-zero if the machine diverged; also runs on entering the repo)
- **Setup**: `ztp.sh` (see README.md; `[dotfiles]` sources go through the `~/.dotfiles` link it creates)
- **Test**: `mise run test`
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
