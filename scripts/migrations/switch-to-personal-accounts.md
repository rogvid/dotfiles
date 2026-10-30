---
name: switch-to-personal-accounts runbook
description: One-off runbook (2026-10) for the temporary claude session on ~/.claude-switch that moves Rogvi's claude onto his personal account (rogvidarge@gmail.com) on the default ~/.claude, merges ~/.claude-personal into it and deletes Flowtale's project history. Self-contained; follow it top to bottom.
---

# Switch claude to the personal account on ~/.claude

You are a temporary claude session that Rogvi started with `CLAUDE_CONFIG_DIR=~/.claude-switch claude` and logged in as rogvidarge@gmail.com.
You run the whole switch-over below, in order, and you are the only claude allowed to run while you do.
Read this whole file before step 1.

## Why

Rogvi is leaving Flowtale.
Until now `~/.claude` held the Flowtale login (rda@flowtale.ai, Max 5x on the company card), and `~/.claude-personal` (the `claudia` alias) held the same login for personal work.
From now on plain `claude` on `~/.claude` is the personal account, and any work account is an exception with a dir and alias of its own (README section "Adding an agent account").
Flowtale's project history is deleted, not migrated.

## Paths

| What | Where |
| --- | --- |
| Dotfiles repo, main worktree | `~/personal/projects/dotfiles/main` (`~/.dotfiles` links to it) |
| The branch with the change | `feat/personal-default-agent-accounts`, worktree `~/personal/projects/dotfiles/feat-personal-default-agent-accounts` |
| The script | `scripts/migrations/switch-to-personal-accounts` in the repo; after the merge `~/.dotfiles/scripts/migrations/switch-to-personal-accounts` |
| This runbook | the same folder, `switch-to-personal-accounts.md` |
| Default config dir, becomes personal | `~/.claude`, with its config file at `~/.claude.json` |
| Old personal dir, merged in then deleted | `~/.claude-personal` |
| Your dir, with the new login | `~/.claude-switch` - never touch it; Rogvi deletes it at the end |
| Agents to resume afterwards | `~/.claude-switch/agents-before-switch.json`, written in step 2 |

## Rules

- Show Rogvi the complete dry-run output (step 5) and wait for his explicit yes before `--apply`.
- When something differs from what this file says, stop and ask Rogvi. Do not work around a blocker.
- Do not delete or move anything in `~/.claude`, `~/.claude-personal` or `~/.claude.json` by hand: the script does it, backs up `~/.claude.json` first, and is safe to re-run.
- Leave the dotfiles repo's uncommitted changes (`git/.config/git/ignore`, `TODO.md`, `agent-sidebar-restore.md`, `claude/`) alone.

## Steps

### 1. Check you are the switch session

```bash
echo "${CLAUDE_CONFIG_DIR}"                                  # /home/kvist/.claude-switch
jq -r .oauthAccount.emailAddress ~/.claude-switch/.claude.json  # rogvidarge@gmail.com
test -s ~/.claude-switch/.credentials.json && echo creds ok
```

Anything else: stop and tell Rogvi.

### 2. Record the running agents

```bash
agent-scan --json > ~/.claude-switch/agents-before-switch.json
jq -r '.[] | select(.harness == "claude") | [.pane_id, .target, .state, (.account | if . == "" then "default" else . end), .session_id] | @tsv' \
  ~/.claude-switch/agents-before-switch.json
```

Expect about seven claude agents on `~/.claude` (`default`, among them the orchestrator) or `~/.claude-personal`, plus yourself on `~/.claude-switch`.
The sidebar also saves agents to `~/.local/state/agent-sidebar/saves.json`, but those saves name `~/.claude-personal`, so do not restore them with the sidebar's `R` after the switch; step 8 resumes them instead.

### 3. Exit the other claude sessions

Show Rogvi the list from step 2 and ask before exiting any agent whose state is not idle (`done`, `waiting` or similar) or that has a `draft`.
Then, for each claude pane that is not yours (account not `~/.claude-switch`):

```bash
tmux send-keys -t <pane_id> -l '/exit' && tmux send-keys -t <pane_id> Enter
```

Check that only you are left:

```bash
for p in $(pgrep -x claude); do printf '%s %s\n' "$p" "$(tr '\0' '\n' </proc/$p/environ | grep ^CLAUDE_CONFIG_DIR=)"; done
```

Only your pid, with `CLAUDE_CONFIG_DIR=/home/kvist/.claude-switch`, may remain.

### 4. Merge and push the branch

```bash
cd ~/personal/projects/dotfiles/main
git fetch origin
git status -sb                      # main, maybe with the uncommitted files above
git merge --ff-only feat/personal-default-agent-accounts
```

If main has moved on and the merge is not a fast-forward, rebase the branch and try again:

```bash
git -C ../feat-personal-default-agent-accounts rebase main
git merge --ff-only feat/personal-default-agent-accounts
```

A rebase conflict: stop and ask Rogvi.
Then:

```bash
mise run test                       # every suite passes
git push origin main
git worktree remove ../feat-personal-default-agent-accounts
git branch -d feat/personal-default-agent-accounts
```

From here this runbook is at `~/.dotfiles/scripts/migrations/switch-to-personal-accounts.md`.

### 5. Dry run, and Rogvi's yes

```bash
~/.dotfiles/scripts/migrations/switch-to-personal-accounts
```

Show Rogvi the whole output, not a summary.
What to expect:

- No `BLOCKER` line. Each one names what to fix (the login, the merge, a claude still running); fix it and dry-run again.
- `~/.claude will be logged in as: rogvidarge@gmail.com`.
- Step 1: `@agent-orchestrator-account` unset, `~/.tmux.conf` re-sourced, and `CLAUDE_CONFIG_DIR` unset in any tmux session that points it at `~/.claude-personal` (`mercury-exp-finetune-local` did).
- Step 2: about 23 `-home-kvist-work-flowtale*` folders deleted from `~/.claude/projects`, and about 2700 of 3350 lines of `~/.claude/history.jsonl` (the Flowtale ones).
  The 7 other folders stay: `-home-kvist`, `-home-kvist--local-share-agent-sidebar-orchestrator` (the orchestrator's history and memory), and the 5 `-home-kvist-personal-projects-*` ones.
- Step 3: every `~/.claude-personal/projects` folder moves in, except `-home-kvist-work-flowtale-projects-mercury`, which is dropped.
  Three folders exist in both and are merged: the orchestrator's, `koyr` (its `memory/MEMORY.md` gains 5 lines) and `skills`.
  A `CLASH` line means both had a different file of that name; the incoming one is kept as `NAME.from-personal`. Point any out to Rogvi.
- Step 4: credentials copied from `~/.claude-switch`, `oauthAccount` set in `~/.claude.json`, which keeps its project trust entries and gains `~/.claude-personal`'s, and a backup in `~/.claude/backups/`.
- Steps 5 and 6: `rm -rf ~/.claude-personal`, `mise bootstrap dotfiles apply`, `agent-setup --check`.

Wait for Rogvi's explicit yes.

### 6. Apply

```bash
~/.dotfiles/scripts/migrations/switch-to-personal-accounts --apply
```

If it fails part-way, show Rogvi the error.
It is safe to re-run once the cause is fixed: each step skips what is already done, and once `~/.claude-personal` is gone it says there is nothing left to do.

### 7. Verify

```bash
ls ~/.claude/projects | grep -c work-flowtale                    # 0
ls -d ~/.claude-personal                                         # No such file or directory
jq -r .oauthAccount.emailAddress ~/.claude.json                  # rogvidarge@gmail.com
find ~/.claude/projects -name '*.from-personal'                  # show Rogvi any
agent-sidebar-tmux accounts                                      # only: claude switch /home/kvist/.claude-switch
tmux show-options -gqv @agent-orchestrator-account               # empty
zsh -ic 'type claudia' 2>&1 | tail -1                            # claudia not found
env -u CLAUDE_CONFIG_DIR claude -p 'Reply with the single word: ok'   # ok
```

`agent-setup --check` ran at the end of the script.
If it reported `would: link ...` (the new `add-agent-account` skill, for one), run `agent-setup` and check again.
If the `claude -p` check fails on authentication, ask Rogvi to run `claude` in a new pane and `/login` as rogvidarge@gmail.com.

### 8. Resume the agents

Each agent from step 2 resumes in its own pane, on the default account, in the conversation it was in:

```bash
jq -r '.[] | select(.harness == "claude" and .account != "/home/kvist/.claude-switch" and (.session_id // "") != "")
       | [.pane_id, (.target | sub(":.*$"; "")), .cwd, .session_id] | @tsv' ~/.claude-switch/agents-before-switch.json |
while IFS=$'\t' read -r pane session cwd id; do
  cmd="env -u CLAUDE_CONFIG_DIR claude --dangerously-skip-permissions --resume ${id}"
  if tmux display-message -p -t "${pane}" '#{pane_id}' >/dev/null 2>&1; then
    tmux send-keys -t "${pane}" -l "${cmd}" && tmux send-keys -t "${pane}" Enter
  else
    agent-sidebar-tmux resume "${session}" "${cwd}" claude "" "${cmd}"
  fi
done
```

Agents without a `session_id` are left out: list them for Rogvi.
Then check with `agent-scan --json | jq -r '.[] | [.target, .harness, .account] | @tsv'` that every claude but you has an empty account (the default), the orchestrator among them.

### 9. Hand back

Tell Rogvi it is done, with anything that differed from this runbook.
He exits you and deletes `~/.claude-switch` himself.
Your credentials were copied into `~/.claude`, so if `claude` asks for a login later, `/login` as rogvidarge@gmail.com once fixes it.
`scripts/migrations/switch-to-personal-accounts`, this runbook, `scripts/tests/test-switch-to-personal-accounts` and their entries in `mise.toml` and `.pre-commit-config.yaml` can go in a later commit.
