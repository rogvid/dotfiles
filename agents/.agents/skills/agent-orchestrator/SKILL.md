---
name: agent-orchestrator
description: Find, start or message the user's orchestrator - the one claude session, in tmux session `orchestrator` and shown with M-1, that keeps track of all the other agents. Use when a task mentions the orchestrator, when you need to report to it, or when asked to start it. For agents in general (agent-scan, agent-msg, spawning workers) use the agent-sidebar skill.
---

# The orchestrator

The user's orchestrator is one claude session that keeps track of all the other agents and relays the user's decisions to them.
It is the tmux session `orchestrator`, which M-1 shows in a popup on the user's screen and hides again; it keeps running while hidden.
The agent-sidebar's settings hide it (`hide = ["orchestrator"]`), so the sidebar and the status bar leave it out, but `agent-scan --json` still lists it with `"hidden": true`.

- Its home is `~/.local/share/agent-sidebar/orchestrator`, a real folder outside every repository, so `agent-scan` shows its `project` as `orchestrator` and its `branch` as `no git`.
- Its `AGENTS.md` and `CLAUDE.md` there are links to `agents/orchestrator/AGENTS.md` in dotfiles; change that file in dotfiles, never the links.
- `projects.md` beside them is the machine's own, untracked list of projects and what speech-to-text turns their names into.
- Its pane, when it runs: `agent-scan --json | jq -r '.[] | select(.target | startswith("orchestrator:")) | .pane_id'`.
- Message it like any other agent, with `agent-msg send PANE "..."` (agent-sidebar skill, section 3).

## Starting it

- `agent-orchestrator start` creates the session if there is none, without showing it, and prints its pane id.
  Start it only when the user asks.
- It types `claude` into a shell in the home, on the claude account the tmux option `@agent-orchestrator-account` names (`tmux show-options -gv @agent-orchestrator-account`; `tmux.conf` sets it), else on the caller's.
  The names are the ones `agent-sidebar-tmux accounts` lists.
  When this machine has no such account, it says so and starts nothing.
- Before it starts claude, it marks the home trusted on that account (`projects[FOLDER].hasTrustDialogAccepted` in the account's `.claude.json`), since claude's trust prompt would otherwise exit on Enter.
- `agent-orchestrator toggle` (M-1) is for the human: it opens a popup.
