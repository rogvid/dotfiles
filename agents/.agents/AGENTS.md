# Rogvi's agent instructions

These are common instructions for Rogvi's agents across all scenarios.
Project specific configuration takes precedence over anything here.

# General Guidelines

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, use conventional commits
- When writing or substantially editing long Markdown files, put each full sentence on its own line. Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it. This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.

# Working with files

- Markdown files should include frontmatter metadata to give better context about their purpose and usage. Include at least `name` and `description`.
- When reading markdown files, start by only reading the frontmatter, then if it is useful, read the entire file. Use bash command line tools like `ripgrep`, `cat`, `find`, and the like to find relevant files and information.

# Environments

- Project environments should be handled using [`mise`](https://mise.jdx.dev/)

# Other agents

- You usually run in a tmux pane next to the agent-sidebar, with other agents in other panes and worktrees.
- To find other agents, see what they are doing, message them, or start an agent in a new worktree, use the `agent-sidebar` skill.
- Address other agents by the tmux pane id `agent-scan` gives, not through your harness's built-in agent messaging: that reaches only sessions of the same harness and does not say which one works on what.

## When to start workers in worktrees

Before you start on a request, check whether it is one for workers.

- It is when it has two or more parts that do not depend on each other (separate features, fixes or investigations) and any part is more than a few lines, or when it would disrupt work in progress on the current branch.
- Then build nothing yet: name one branch per part, offer to start a worker for each in its own worktree, and wait for the user's answer.
- Otherwise do the work yourself in the current worktree.
- Never start workers without the user's go-ahead: each one costs usage and adds a tmux session.
- When the user agrees, or asks for workers directly, start them with the `agent-sidebar` skill's `spawn`, not your harness's built-in worktree subagents, so they show up in the sidebar.

# Python

- Prefer [`uv`](https://docs.astral.sh/uv/) for python environments and package management and for one-off scripts
- Prefer [`loguru`](https://github.com/Delgan/loguru) for logging
- Prefer [`textual`](https://github.com/Textualize/textual) for writing TUIs

# Web

- Prefer a single styles.css file for website styling unless there is a very good reason not to.
- Prefer a single page html for conceptual prototypes unless there is a very good reason not to.
- Prefer react + tailwindcss for websites unless there is a very good reason not to.
- Prefer using beautiful components from component libraries like [`shadcn`](https://ui.shadcn.com/) over building custom components unless there is a very good reason not to.

# Scripts

- When building scripts to be executed from the command line, prefer bash scripts.
- If the functionality is complex or can't be done in bash prefer python scripts. Always make `uv` scripts (see https://docs.astral.sh/uv/guides/scripts/#declaring-script-dependencies). The main requirements for a `uv` based script is to add something like the following to the top of the script:

```bash
#!/usr/bin/env -S uv run --script
# vim: set ft=python:
# -*- mode: python -*-
# language: python
# /// script
# requires-python = ">=3.12"
# dependencies = [
    <add dependencies here/>
# ]
# ///
<add script code after this block/>
```

# Non-negotiable principles

- Surface assumptions before building. Wrong assumptions held silently are the most common failure mode.
- Stop and ask when requirements conflict. Don't guess.
- Push back when warranted. The agent (or engineer) is not a yes-machine.
- Prefer the boring, obvious solution. Cleverness is expensive.
- Touch only what you're asked to touch.
- When reporting information to be extremely concise and sacrifice grammar for concision
