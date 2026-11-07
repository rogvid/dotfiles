---
name: web-app-stack-deploy
description: How an app gets onto the webhost vps-1 - the pull-based deploy model, the steps in the provisioning repo (DNS, app:new, app:key, secrets, dump hook) and in the app repo (deploy workflow with Sentry build inputs), and the rules the app template enforces.
---

# Deploying to the webhost

The source of truth is the provisioning repo, `~/personal/projects/provisioning`.
Read its `docs/runbooks/webhost.md` before deploying anything; this file only says how an app plugs in and what is decided.
Why it works this way: `docs/reviews/2026-11-06-webhost.md` and ADRs 0001 to 0005 there.

## The model

- CI builds the image and pushes `ghcr.io/rogvid/<app>:sha-<commit>`; the VPS never builds and never receives source.
- CI then runs `ssh deploy@<host> deploy <app> sha-<commit>`. The `deploy` account can run only that command, and each app's key only for its own app.
- `app-deploy` on the host pulls, runs the app's dump hook, switches the tag, waits for healthy and rolls back to the previous tag if it never gets there.
- The host's Caddy terminates HTTPS for every app and proxies to `127.0.0.1:<port>`; apps never publish on another address and never run their own proxy.
- The app's `compose.yaml`, `app.env` and Caddy site live in the provisioning repo's host layer (`hosts/mise.vps-1.toml`), so a deploy key can change which image runs and nothing else.
- Secrets go in `hosts/secrets/vps-1.sops.yaml` and reach `app.env` through `secret(name='...')`; never in the app repo, never in GitHub except the deploy key and build-time tokens.

## Steps

In the provisioning repo, from `docs/runbooks/webhost.md`:

1. **DNS**: an A record (and AAAA if the VPS has IPv6) for the app's domain.
2. **Host layer**: `mise run app:new <app> <domain>`, then edit the block it appends:
   - the healthcheck command and the app's health path ([stack.md](stack.md));
   - a Postgres `db` service and its dump hook, if the app has a database;
   - `data/` mounts for files the app keeps;
   - `app.env`: `ENVIRONMENT=production`, `SENTRY_DSN`, and the app's own settings, secrets through sops.
3. **Deploy key**: `mise run app:key <app> rogvid/<app>`, plus the `DEPLOY_HOST` variable and `DEPLOY_KNOWN_HOSTS` secret it describes.
4. Commit, `mise run apply vps-1`.

In the app repo:

5. **Workflow**: `.github/workflows/deploy.yml` from the runbook's "The workflow", with the Sentry build inputs added to the build step:

   ```yaml
   - uses: docker/build-push-action@v6
     with:
       push: true
       tags: ghcr.io/rogvid/<app>:sha-${{ github.sha }}
       build-args: |
         GIT_SHA=${{ github.sha }}
         VITE_SENTRY_DSN=${{ vars.SENTRY_DSN_WEB }}
       secrets: |
         SENTRY_AUTH_TOKEN=${{ secrets.SENTRY_AUTH_TOKEN }}
   ```

   The Dockerfile reads the token only through `RUN --mount=type=secret,id=SENTRY_AUTH_TOKEN,env=SENTRY_AUTH_TOKEN` on the frontend build step, never as an `ARG`, so it stays out of the image.
6. **Repository settings**: variable `SENTRY_DSN_WEB` (public), secret `SENTRY_AUTH_TOKEN` (Sentry org auth token); in the `production` environment for a public repository, like the deploy key.
7. Push to `main`; the first deploy starts the app. Check with `ssh kvist@vps-1 sudo app-deploy status <app>`.

## Rules the template enforces

From the template in the provisioning repo (`templates/app.toml`), explained in the runbook's "The app template":

- read-only root filesystem with a `/tmp` tmpfs, all capabilities dropped, `no-new-privileges`;
- `mem_limit: 256m`, `cpus: 0.5` until the app shows it needs more;
- a healthcheck that a deploy waits on;
- Caddy holds requests for up to 30 s during a redeploy instead of returning 502.

Build the app to live within these ([stack.md](stack.md)); loosen one only with a reason written next to it.

## Data and backups

- Files the app keeps: under `/srv/apps/<app>/data`, bind-mounted.
- Database: a named volume, plus the dump hook `app:new` writes commented out; uncomment it for Postgres.
- Every night, and before every deploy, the dump hook runs; restic takes `data/` and `dumps/` off-site (`docs/runbooks/backups.md` in the provisioning repo, including the monthly restore test).

## Removing an app

The runbook's "Removing an app": compose down, mark the layer's entries absent, apply, then delete the entries, the deploy key line and the DNS record.
Also delete or archive its Sentry projects and its uptime check.
