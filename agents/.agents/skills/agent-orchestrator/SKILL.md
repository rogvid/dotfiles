---
name: agent-orchestrator
description: Find, start or message Hugin - Rogvi's desk, formerly "the orchestrator" - the one claude session, in tmux session `hugin` and shown with M-1, that keeps track of all the other agents. Use when a task mentions Hugin or the orchestrator, when you need to report to it, or when asked to start it. For agents in general (agent-scan, agent-msg, spawning workers) use the agent-sidebar skill.
---

# Hugin, the desk

Hugin is Rogvi's desk: one claude session that keeps track of all the other agents and relays his decisions to them.
It used to be called the orchestrator.
It is the tmux session `hugin`, which M-1 shows in a popup on the user's screen and hides again; it keeps running while hidden.
The agent-sidebar's settings hide it (`hide = ["hugin"]`), so the sidebar and the status bar leave it out, but `agent-scan --json` still lists it with `"hidden": true`.

- Its home is the main worktree of its own private repo, `~/personal/projects/hugin/main` ([rogvid/hugin](https://github.com/rogvid/hugin)), so `agent-scan` shows its `project` as `hugin`.
- It runs as `claude --agent hugin --remote-control Hugin`, so the Claude app lists it as `Hugin` (no other agent has Remote Control on); its identity is `profiles/hugin/IDENTITY.md` in that repo, its rules are in `lovir/`, its memory in `munin/memory/`.
  Change them in that repo, through a PR Rogvi approves.
- Its pane, when it runs: `agent-orchestrator pane`, which fails unless exactly one Hugin agent runs.
- Message it like any other agent, with `agent-msg send PANE "..."` (agent-sidebar skill, section 3).

## Starting it

- `agent-orchestrator start` creates the session if there is none, without showing it, and prints the pane running Hugin.
  It fails when an existing session does not have exactly one.
  Start it only when the user asks.
- It types `claude --agent hugin --remote-control Hugin` into a shell in the home, on the claude account the tmux option `@agent-orchestrator-account` names (`tmux show-options -gv @agent-orchestrator-account`; `tmux.conf` sets it), else on the caller's.
  The names are the ones `agent-sidebar-tmux accounts` lists.
  When this machine has no such account, it says so and starts nothing.
- Without the hugin repo, it says how to clone it and starts nothing.
- Before it starts claude, it marks the home trusted on that account (`projects[FOLDER].hasTrustDialogAccepted` in the account's `.claude.json`), since claude's trust prompt would otherwise exit on Enter.
- `agent-orchestrator toggle` (M-1) is for the human: it opens a popup.
