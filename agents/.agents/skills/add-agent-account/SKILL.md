---
name: add-agent-account
description: Add or remove another subscription for claude, codex or pi next to Rogvi's personal one - a work account, a client's, a second plan. Use when asked to add a work account, set up another claude/codex/pi login, give a harness a second config dir, run the orchestrator on another account, or remove such an account.
---

# Adding an agent account

Plain `claude`, `codex` and `pi` on their default config dirs (`~/.claude`, `~/.codex`, `~/.pi/agent`) are Rogvi's personal accounts.
Every other account is the exception: a config dir of its own, `~/.claude-NAME`, `~/.codex-NAME` or `~/.pi-NAME/agent`, and an alias that starts the harness on it.
`agent-setup`, `agent-sidebar-tmux accounts` and the sidebar find accounts by that naming pattern, so keep to it.

The steps live in one place: the section "Adding an agent account" in `~/.dotfiles/README.md`.
Read it and follow it in order; do not work from memory of an older layout (`claudia`, `~/.claude-personal`), which is gone.

## Before you start

Ask Rogvi, unless the request already says:

- The account's NAME: short and lowercase. It becomes the dir suffix, the alias (`claude-NAME`) and the name `agent-sidebar-tmux accounts` lists.
- Which harnesses get it.
- Whether the orchestrator should run on it. The default is no: it stays on the personal account.

## What only Rogvi can do

Logging in.
Once the dir, alias and links are in place, ask him to open a new shell, run the alias and `/login` (codex: `codex login`).

## Done when

- `agent-sidebar-tmux accounts` lists the account with its folder.
- `agent-setup --check` reports nothing to change.
- `mise run test` passes in the dotfiles repo.
- Started through its alias, the harness shows the new account (`/status` in claude).

Commit the dotfiles changes the way the dotfiles repo's own instructions say.
