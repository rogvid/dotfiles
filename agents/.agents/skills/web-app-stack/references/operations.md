---
name: web-app-stack-operations
description: Running Rogvi's web apps after the first deploy - uptime checks (Gatus at home, planned), host heartbeats on Healthchecks.io, backups and restore tests, where alerts go, and what is proposed but not decided yet (issue labels, severity, agent triage and fixes, scheduled rebuilds).
---

# Operations

## Decided

| What | How | Where it lives |
|---|---|---|
| Uptime of each app's URL | **Gatus**, on a small VM on the Proxmox server at home, alerting through ntfy to Rogvi's phone; it pings a Healthchecks.io check so a dead Gatus is noticed too | Gatus's checks in the provisioning repo, one per app, added with the app. **Not built yet**: until it exists, say so when an app goes live and offer to build it. |
| Unattended host jobs (nightly backup, security updates) | `heartbeat <check> start\|success\|fail` to Healthchecks.io, which alerts when a ping fails or does not come | provisioning repo: `hosts/mise.toml` (heartbeats), `docs/runbooks/backups.md` (Heartbeats) |
| App errors | Sentry, with Sentry's own alert on new issues | [sentry.md](sentry.md) |
| Backups | Dump hook before every deploy and nightly; restic to Backblaze B2 nightly; a monthly restore test | provisioning repo: `docs/runbooks/backups.md` |
| Host patching | Unattended upgrades for Ubuntu, Docker, Caddy and Tailscale, reboot at 04:30 UTC when needed | provisioning repo: `hosts/mise.webhost.toml` |
| Logs | `docker compose logs` on the host; nothing shipped elsewhere | provisioning repo: `docs/runbooks/webhost.md`, Day to day |

Monitoring never runs on the box it watches: vps-1 cannot report its own outage.

For each new app, once it is live:

1. A Gatus check on its public URL, hitting a real page and the health endpoint (or, until Gatus exists, a note to Rogvi that the app is unwatched).
2. If it has a database: run its dump hook once by hand (`ssh kvist@vps-1 sudo /usr/local/sbin/app-deploy dump <app>`) and include it in the next restore test.
3. A Sentry alert on new issues in its projects, to Rogvi's email or phone.

## Proposed, not decided

From the webhost review (`docs/reviews/2026-11-06-webhost.md` in the provisioning repo, section e and items D5, 9).
Raise these with Rogvi when they become relevant rather than doing them unasked:

- GitHub Issues per app repo, one GitHub Project as the board, shared labels and issue forms from a `rogvid/.github` repo.
- Severity labels `sev:1` to `sev:4`, with uptime alerts and new Sentry issues starting at sev:1 or sev:2.
- Sentry linked to GitHub so an issue can open or link a GitHub issue, and `Fixes <SHORT-ID>` in a commit resolves it.
- `anthropics/claude-code-action` to triage new issues and, on an `agent:fix` label Rogvi sets, reproduce the bug as a failing end-to-end test, fix it and open a PR; never auto-merged, never with access to the deploy key.
- A weekly scheduled rebuild and redeploy so base-image patches arrive for quiet apps, plus Dependabot or Renovate.
