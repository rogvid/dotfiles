---
name: web-app-stack-stack
description: The default stack for Rogvi's web apps (FastAPI + Vite React SPA with Tailwind and shadcn, Postgres, one image), the repository layout, mise tasks, and what an image must do to run on the webhost.
---

# The default stack

Use this once Rogvi has agreed to it for the project (SKILL.md, "Starting a new project").

## Pieces

| Part | Choice | Why |
|---|---|---|
| Backend | Python 3.13, FastAPI, pydantic-settings, SQLAlchemy 2 + Alembic, `loguru` for logs | Fast to write, typed, one process |
| Python tooling | `uv` (lockfile committed), `ruff`, `pytest` | Rogvi's defaults |
| Frontend | Vite + React + TypeScript, Tailwind, shadcn components | Rogvi's defaults; a static build needs no Node in production |
| Styling | One `styles.css` (Tailwind entry) | Rogvi's preference |
| Database | Postgres 17 as a second Compose service when the app needs one; SQLite for local dev and tests is fine | Postgres has a dump hook on the webhost; SQLite files are not safe to copy mid-write |
| Tools and tasks | `mise.toml` pins Python and Node and defines the tasks | Rogvi's environment manager |

## One image

FastAPI serves the API under `/api` and the built SPA for everything else, from one container on one port.
That fits the webhost template (one `app` service, one port on 127.0.0.1) with no CORS and no second container.

- A multi-stage Dockerfile: a Node stage runs `npm ci && npm run build`; the final stage is Python slim with `uv sync --frozen --no-dev` and copies the SPA's `dist/` in.
- Mount `dist/` with `StaticFiles(html=True)` after the API routers, plus a fallback that returns `index.html` for client-side routes (not for `/api/*`, which must 404).
- Pass the git SHA in as a build argument and set it as `SENTRY_RELEASE` in the image ([sentry.md](sentry.md)).

## What the image must do on the webhost

The webhost runs every container locked down ([deploy.md](deploy.md)), so build for it from the start:

- **Health endpoint**: `GET /api/health` returns 200 without touching anything slow. The Compose healthcheck runs inside the container, so the image needs the tool it uses: in a Python image, `python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/api/health')"`.
- **Read-only root filesystem**: only `/tmp` (a small tmpfs) and declared volumes are writable. Uploads go to a path mounted from `data/`; no writing next to the code.
- **No capabilities, non-root where possible**: listen on a port above 1024 (8080 by default) and run as a fixed non-root UID if the image allows.
- **Run from the venv, not `uv run`**: `uv run` writes a cache at start and dies on a read-only filesystem. Call `.venv/bin/alembic` and `.venv/bin/uvicorn` directly, and precompile bytecode at build time.
- **Fixed UID 10001**: data the app writes under `data/` must be owned by that UID on the host. mise bootstrap takes owner names, not numbers, so the host layer adds a no-login system account `app-<app>` with UID and GID 10001 (the provisioning runbook `docs/runbooks/webhost.md` shows how).
- **Migrations on start**: `alembic upgrade head` before the server starts; the deploy's dump hook runs first, so a bad migration has a fresh dump to go back to.
- **Config from the environment only**: every setting through pydantic-settings from `app.env`; `ENVIRONMENT=production` refuses to boot with development secrets.
- **Logs to stdout**.

## Repository

`rogvid/<app>` on GitHub, lowercase, matching the image name.

```
<app>/
  backend/            FastAPI app, alembic/, tests/, pyproject.toml, uv.lock
  frontend/           Vite app, package.json, package-lock.json
  Dockerfile          the one production image
  compose.yaml        local prod-like run only (the server's lives in the provisioning repo)
  mise.toml           tools and tasks
  scripts/smoke.sh    boots the built image and checks it end to end
  .github/workflows/  ci.yml and deploy.yml (deploy.md)
```

`mise.toml` tasks every app has: `setup`, `dev` (backend with reload and Vite dev server, proxying `/api`), `test` (pytest, type-check, lint), `smoke` (build the image, run it read-only like the webhost does, hit health and a real page).
The smoke test is the end-to-end check before any deploy, and the place to reproduce bugs as a user would.

## When the default does not fit

- **Next.js alone**: when server rendering or SEO dominate and the backend is a few routes. Build with `output: 'standalone'` (it cut one image from 1.5 GB to 341 MB), set `HOSTNAME=0.0.0.0`, and give `.next/cache` a tmpfs under the read-only filesystem. Its Sentry setup differs ([sentry.md](sentry.md)).
- **Postgres under the template's hardening**: with no capabilities its entrypoint cannot chown or switch user, so it runs as `user: "999:999"` (the image's postgres user, which owns the volume) with a tmpfs for `/var/run/postgresql`; copy the hardened example in the provisioning runbook (`docs/runbooks/webhost.md`, Data and backups), and keep its password in a separate `db.env` so the database container does not hold the app's secrets.
- **Go or Rust binary**: a tiny API, proxy or worker. Static binary in a distroless or scratch image; the healthcheck has to be a subcommand of the binary itself, since there is no shell or wget.
- **Two containers (API + frontend server)**: only when both are needed; the Caddy site then routes `/api/*` to one port and the rest to the other, and the template's single `app` service becomes two.
