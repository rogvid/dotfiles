---
name: web-app-stack
description: Rogvi's decisions for building and running web apps - how a new project starts (what are we building, then which stack), the default stack (FastAPI + Vite React SPA in one image), deploying to the webhost vps-1 from GitHub Actions through the provisioning repo, Sentry error monitoring with its privacy rules, uptime checks, heartbeats and backups. Use when starting a new web app, site, API or service, choosing a stack, adding deploys, CI, Sentry, monitoring or backups to an app, or moving an existing app onto the webhost.
---

# Web app stack

Everything already decided for Rogvi's web apps, so a new one starts from decisions instead of a blank page.
The provisioning repo is the source of truth for hosts and deploys; this skill points into it rather than copying it, so read the files it names before acting on them.

## Starting a new project: decide what it is before the stack

Never lock in a stack from the request alone.
First work out with Rogvi, in a short conversation (the `grilling` skill fits), what is being built:

1. What it does, for whom, and the one thing that must work on day one.
2. Shape: static site, API only, interactive app, background job, or a mix.
3. State: none, files, a relational database, or something special (search, queues, realtime).
4. Who logs in, and whether it handles personal data (it usually does: see the privacy rules in [sentry.md](references/sentry.md)).
5. Anything that forces a choice: SEO and server rendering, an existing codebase, a library only one language has.

Then propose a stack with one line of reasoning and get a yes before writing code.
The default below fits most apps; say so when something else is simpler.

| Situation | Stack |
|---|---|
| Default: an app with an API and a UI | FastAPI + Vite React SPA (Tailwind, shadcn), one image: [stack.md](references/stack.md) |
| SEO-heavy or server-rendered pages matter most | Next.js alone, if the backend is thin |
| A small API, proxy or worker with no UI | One Go or Rust binary in a scratch or distroless image |
| A static site | Static files; ask whether it needs vps-1 at all (GitHub Pages is free) |

Whatever the stack, the deploy, Sentry and operations decisions below still apply; adapt the mechanics, not the rules.

## What every app gets

| Concern | Decision | Details |
|---|---|---|
| Tools and tasks | `mise` (`mise.toml` with `dev`, `test`, `smoke` tasks); `uv` for Python; npm for the frontend | [stack.md](references/stack.md) |
| Repository | `rogvid/<app>` on GitHub; conventional commits | [stack.md](references/stack.md) |
| Hosting | The webhost vps-1: one Compose project in `/srv/apps/<app>`, behind the host's Caddy | [deploy.md](references/deploy.md) |
| Deploys | Push to `main` builds `ghcr.io/rogvid/<app>:sha-<commit>` in GitHub Actions, then `deploy <app> <tag>` over SSH; failed health means automatic rollback | [deploy.md](references/deploy.md) |
| Config and secrets | Compose file and `app.env` live in the provisioning repo; secrets in its sops files, never in the app repo | [deploy.md](references/deploy.md) |
| Data | Files under `data/`, a database dump hook, nightly restic off-site | [deploy.md](references/deploy.md) |
| Errors and traces | Sentry org `kvist-nt` (EU), one project per runtime, strict privacy settings, verified by a test | [sentry.md](references/sentry.md) |
| Uptime | Gatus at home on Proxmox, checks in the provisioning repo (planned, not built yet) | [operations.md](references/operations.md) |
| Host jobs | Healthchecks.io heartbeats, already on every host | [operations.md](references/operations.md) |

## Order of work for a new app

1. The conversation above, and a stack Rogvi agreed to.
2. Scaffold from [stack.md](references/stack.md): health endpoint, Dockerfile that runs read-only, `mise` tasks, a smoke test of the built image.
3. Sentry from [sentry.md](references/sentry.md), including its privacy test, and confirm a real error lands.
4. Deploy from [deploy.md](references/deploy.md): DNS, `app:new`, `app:key`, the workflow, the first deploy.
5. Operations from [operations.md](references/operations.md): uptime check, dump hook if it has a database, a restore check.

Each step that touches the provisioning repo (`~/personal/projects/provisioning`) is a change there too, with its own commit.

## Where an app differs: recorded in the app, not here

This skill holds only what applies to every app.
Each app may differ from it where Rogvi agreed to: another stack, two containers, other health paths, ports, Sentry project names that predate the convention, a deploy trigger.
Those choices live in the app's own repository, in its `AGENTS.md` under a `## Stack choices` heading, one line each with the reason.

- Working on an existing app: read that section first; where it says something different, it wins over this skill.
- When Rogvi agrees to a difference (in the start-of-project conversation or later), add it there, never here.
- An app with no such section follows this skill exactly.
- Examples of apps already on the model: the `app:` blocks in the provisioning repo's `hosts/mise.vps-1.toml`.
