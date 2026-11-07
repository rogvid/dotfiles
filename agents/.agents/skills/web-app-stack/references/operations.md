---
name: web-app-stack-operations
description: Running Rogvi's web apps after the first deploy - uptime checks (Gatus on the home VM mon), host heartbeats on Healthchecks.io, backups and restore tests, where alerts go, and what is proposed but not decided yet (issue labels, severity, agent triage and fixes, scheduled rebuilds).
---

# Operations

## Decided

| What | How | Where it lives |
|---|---|---|
| Uptime of each app's URL | **Gatus** on `mon`, a small VM on the Proxmox server at home, alerting through an ntfy.sh topic to Rogvi's phone; it pings the Healthchecks.io check `mon-gatus` every minute, so a dead Gatus, VM, node or home uplink alerts too | provisioning repo: `hosts/files/gatus/endpoints/<app>.yaml` (one per app, written by `app:new`), `hosts/mise.mon.toml`, `docs/runbooks/monitoring.md`. Built; check whether `mon` has been created before relying on it. |
| Unattended host jobs (nightly backup, security updates) | `heartbeat <check> start\|success\|fail` to Healthchecks.io, which alerts when a ping fails or does not come | provisioning repo: `hosts/mise.toml` (heartbeats), `docs/runbooks/backups.md` (Heartbeats) |
| App errors | Sentry, with Sentry's own alert on new issues | [sentry.md](sentry.md) |
| Where alerts go | One ntfy.sh topic for Gatus and Healthchecks.io; Gatus's alerting is one block in `hosts/files/gatus/config.yaml`, so it can be repointed (Gjallarhorn, later) | provisioning repo |
| Uptime for other tools | Gatus's read-only status API on mon's `127.0.0.1:8080` (`/api/v1/endpoints/statuses` and friends), through an SSH tunnel under the current tailnet policy; Valhalla and Heimdall read it | provisioning repo: `docs/runbooks/monitoring.md`, The status API |
| Backups | Dump hook before every deploy and nightly; restic to Backblaze B2 nightly; a monthly restore test | provisioning repo: `docs/runbooks/backups.md` |
| Host patching | Unattended upgrades for Ubuntu, Docker, Caddy and Tailscale, reboot at 04:30 UTC when needed | provisioning repo: `hosts/mise.webhost.toml` |
| Logs | `docker compose logs` on the host; nothing shipped elsewhere | provisioning repo: `docs/runbooks/webhost.md`, Day to day |

Monitoring never runs on the box it watches: vps-1 cannot report its own outage.

For each new app, once it is live:

1. Uptime checks: `app:new` writes them (a real page with certificate expiry, and the health endpoint; `--health-path` when it is not `/api/health`). Make them match the app, run `mise run gatus:check`, and `mise run apply mon` once the app is live.
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
