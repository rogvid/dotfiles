---
name: issue-tracking
description: "File-based issue tracking system with dependency management, inspired by Steve Yegge's Beads. Uses markdown files with YAML frontmatter stored in a `tasks/` directory, providing a minimal yet powerful CLI for managing tickets, dependencies, and workflows."
metadata:
  url: https://github.com/wedow/ticket/tree/master
  author: wedow
  upstream: Steve Yegge's Beads
  version: 1.0.0
---

# Issue Tracking Skill

## Overview

This skill provides a minimal, file-based issue tracking system implemented as a portable bash script (`tk`). It's based on the [wedow/ticket](https://github.com/wedow/ticket) repository, which itself is a simplified version of Steve Yegge's Beads issue tracking system.

The system stores tickets as markdown files with YAML frontmatter in a `tasks/` directory, making them:
- **Git-friendly**: Easy to version control, diff, and merge
- **Human-readable**: Plain text files that can be edited manually or with the CLI
- **Portable**: No database required, works on any Unix-like system
- **Flexible**: Supports complex workflows with dependencies, priorities, and custom metadata

## Core Concepts

### Ticket Structure

Each ticket is a markdown file with:
- **YAML Frontmatter**: Structured metadata (status, dependencies, assignee, etc.)
- **Markdown Body**: Title, description, design notes, acceptance criteria, and timestamped notes

### Ticket IDs

Tickets use auto-generated IDs based on:
1. Directory name initials (e.g., `my-project` → `mp`)
2. 4-character hash from timestamp + PID for uniqueness
3. Format: `<prefix>-<hash>` (e.g., `mp-a7f3`)

Supports **partial ID matching** for convenience (e.g., `tk show a7` matches `mp-a7f3` if unique).

### Ticket Metadata

- **id**: Unique identifier
- **status**: `open`, `in_progress`, or `closed`
- **type**: `bug`, `feature`, `task`, `epic`, or `chore`
- **priority**: 0-4 (0 = highest priority)
- **assignee**: Person responsible for the ticket
- **created**: ISO 8601 timestamp
- **deps**: Array of ticket IDs this ticket depends on
- **links**: Array of related ticket IDs (symmetric relationships)
- **parent**: Parent ticket ID (for sub-tasks/epics)
- **external-ref**: External reference (e.g., GitHub issue, JIRA ticket)
- **tags**: Array of custom tags

## Usage

Run the script to see available commands:
```bash
scripts/tk
```

### Common Commands

**Create a ticket:**
```bash
scripts/tk create "Fix login bug" -t bug -p 0 -d "Users can't log in with special characters"
```

**List tickets:**
```bash
scripts/tk ls                    # All tickets
scripts/tk ls --status=open      # Only open tickets
scripts/tk ready                 # Tickets ready to work on (deps resolved)
scripts/tk blocked               # Tickets blocked by dependencies
```

**Manage ticket lifecycle:**
```bash
scripts/tk start <id>            # Start working on a ticket
scripts/tk close <id>            # Close a ticket
scripts/tk reopen <id>           # Reopen a closed ticket
```

**Manage dependencies:**
```bash
scripts/tk dep <id> <dep-id>     # Add dependency (id depends on dep-id)
scripts/tk dep tree <id>         # Show dependency tree
scripts/tk undep <id> <dep-id>   # Remove dependency
```

**View and edit:**
```bash
scripts/tk show <id>             # Display ticket
scripts/tk edit <id>             # Open in $EDITOR
scripts/tk add-note <id> "text"  # Add timestamped note
```

**Advanced queries:**
```bash
scripts/tk query                           # Export all tickets as JSON
scripts/tk query '.[] | select(.type == "bug")'  # Filter with jq
```

## AI Agent Integration

When using this skill, AI agents should:

1. **Initialize the system** by ensuring the `tasks/` directory exists
2. **Create tickets** for planned work using appropriate types, priorities, and descriptions
3. **Track dependencies** between tasks to manage complex workflows
4. **Update status** as work progresses (open → in_progress → closed)
5. **Add notes** to document decisions, blockers, or progress updates
6. **Query tickets** to understand current work state and prioritize next actions

### Example Agent Workflow

```bash
# Create a feature ticket
ID=$(scripts/tk create "Add user authentication" -t feature -p 1)

# Create dependent tickets
DB_ID=$(scripts/tk create "Set up user database schema" -t task -p 1)
API_ID=$(scripts/tk create "Implement auth API endpoints" -t task -p 1)
UI_ID=$(scripts/tk create "Build login UI" -t task -p 2)

# Set up dependencies
scripts/tk dep "$API_ID" "$DB_ID"  # API depends on database
scripts/tk dep "$UI_ID" "$API_ID"  # UI depends on API

# Work on ready tasks
scripts/tk ready                    # Shows DB task (no deps)
scripts/tk start "$DB_ID"
# ... do work ...
scripts/tk close "$DB_ID"

scripts/tk ready                    # Now shows API task
```

## File Format Example

```markdown
---
id: mp-a7f3
status: in_progress
deps: [mp-b2c1]
links: []
created: 2026-01-13T10:30:00Z
type: feature
priority: 1
assignee: Jane Doe
tags: [authentication, security]
---
# Add user authentication

Implement JWT-based authentication for the API.

## Design

- Use bcrypt for password hashing
- JWT tokens with 24h expiration
- Refresh token mechanism

## Acceptance Criteria

- [ ] Users can register with email/password
- [ ] Users can log in and receive JWT token
- [ ] Protected endpoints validate JWT
- [ ] Tokens can be refreshed

## Notes

[2026-01-13T14:20:00Z] Started implementation of user model
```

## Integration with Development Workflow

This skill works particularly well with:
- **Git workflows**: Tickets in version control, branch-per-ticket patterns
- **Documentation**: Tickets serve as planning and decision records
- **Team collaboration**: Plain text enables easy code review of ticket changes
- **Automation**: JSON export enables scripting and custom tooling

## Migration from Beads

If you have existing tickets from Steve Yegge's Beads system:
```bash
scripts/tk migrate-beads
```

This imports tickets from `.beads/issues.jsonl` into the `tasks/` directory.
