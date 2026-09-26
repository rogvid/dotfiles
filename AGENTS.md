# Agent Guidelines for Dotfiles Repository

## Build/Test/Deploy Commands
- **Deploy**: `mise bootstrap` (tools, packages, services and every `[dotfiles]` symlink)
- **Check for drift**: `mise run drift` (non-zero if the machine diverged; also runs on entering the repo)
- **Setup**: `ztp.sh` (see README.md; `[dotfiles]` sources go through the `~/.dotfiles` link it creates)
- **Test**: `mise run test`
- **Lint**: `stylua` for Lua files (nvim config), `shellcheck` for shell scripts

## Reviews and Evals When Claude Usage Runs Out
- Reviews and evals here run on Claude by default: subagents, `/code-review` and `claude -p`.
- When one fails on the personal account's usage limit (HTTP 429, "You've hit your session limit · resets <time>"), note the reset time and run reviews and evals with `opencode-free "<prompt>"` until then, without retrying Claude first.
- `opencode-free` runs OpenCode's free models (big-pickle, then nemotron-3-ultra-free) in the current directory and keeps them off the user's tmux server.
- Never call `opencode run` directly for this: reviewing models run tmux to test their ideas, and one typed into the calling pane.
- Give it the brief a Claude reviewer would get, naming the diff or files to read.

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
