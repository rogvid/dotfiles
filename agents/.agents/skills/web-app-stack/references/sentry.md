---
name: web-app-stack-sentry
description: Sentry for Rogvi's web apps - the org and project conventions, where the DSN, release and auth token go in the webhost model, the privacy rules every app must follow and the templates and test that enforce them, sampling and quota choices, source maps, verification, and SDK gotchas learned the hard way.
---

# Sentry

Use the Sentry MCP tools and the `sentry:*` skills for the mechanics (creating projects, reading issues, SDK docs).
This file is what is already decided for Rogvi's apps.

## Org and projects

- Org `kvist-nt`, EU region (`https://de.sentry.io`), team `kvist`, free plan.
- One project per runtime, named after the app: `<app>-api` (platform `python-fastapi`) and `<app>-web` (`javascript-react`, or `javascript-nextjs`).
  Separate projects keep source maps, platforms and quotas apart.
- Create them with the MCP `create_project` after Rogvi says yes; it returns the DSN.
- One-time org settings, in Sentry's web UI (Settings, Security & Privacy), which the agent cannot change: **Prevent Storing of IP Addresses** on, and the data scrubber with its defaults on.
  These are the backstop if an SDK setting ever slips; check them once when setting up an app.

## Where things go (webhost model)

| What | Where | Secret? |
|---|---|---|
| API DSN | `SENTRY_DSN` in the app's `app.env`, in the provisioning repo's host layer | No (a DSN only allows sending events), but it lives with the app's config |
| Web DSN | GitHub variable `SENTRY_DSN_WEB`, baked into the build as `VITE_SENTRY_DSN` | No |
| Release | The git SHA: build arg `GIT_SHA` from `github.sha`, set as `SENTRY_RELEASE` in the image and as the release of the uploaded source maps | No |
| Environment | `ENVIRONMENT=production` in `app.env`; `development` locally | No |
| Source map upload | Org auth token as GitHub secret `SENTRY_AUTH_TOKEN`, a Docker build secret, never an `ARG` | Yes |

Workflow and Dockerfile lines: [deploy.md](deploy.md), step 5.
Empty DSN means the SDK is off, which is what tests, CI and smoke runs use.

## Privacy rules (every app, no exceptions)

Users are real people, often in a small community where a name, an IP or a search is enough to identify someone.
Nothing that identifies a user, or that a user typed, goes to Sentry:

- no IP addresses, from the connection or from `X-Forwarded-For` and similar headers (Caddy sets them);
- no location: Sentry derives a city from the connection's address unless the event already has one, even with IPs not stored and `ip_address` empty, so every event carries an empty `user.geo` (seen on real events, 21 November 2026);
- no cookies, auth headers or tokens;
- no request or response bodies (logins, registrations, messages);
- no query strings (reset links carry tokens, OAuth callbacks carry codes, searches carry what people typed);
- no stack-frame local variables (they hold whole requests and, in auth handlers, passwords);
- no user fields filled in automatically; set an opaque user ID by hand only if it helps triage;
- no Session Replay (Sampling and quota says why).

Stack traces, routes (`/listings/{id}`), status codes, timings and release are what Sentry is for, and enough.

The SDK options alone do not deliver this, so every app uses the templates and the test:

| Runtime | Template | What it does |
|---|---|---|
| Python (FastAPI) | [assets/sentry.py](../assets/sentry.py) as `app/core/sentry.py` | `send_default_pii=False`, `include_local_variables=False`, `max_request_body_size="never"`, ignores the `uvicorn.access` logger, and `before_send` / `before_send_transaction` strip query strings, cookies, bodies and IP headers; `init_sentry()` before `FastAPI()` |
| Python test | [assets/test_sentry_privacy.py](../assets/test_sentry_privacy.py) in `tests/` | Runs the app with the real options against an in-memory transport, sends IP headers, a cookie, a token, a login body and a query string, and fails if any of it is sent |
| Browser / Next.js | [assets/sentry-privacy.ts](../assets/sentry-privacy.ts) | Names every `dataCollection` category, plus `beforeSend` / `beforeSendSpan` scrubbers; spread `...sentryPrivacy` into every `Sentry.init` |

The Python template expects settings `ENVIRONMENT`, `SENTRY_DSN`, `SENTRY_RELEASE` and `SENTRY_TRACES_SAMPLE_RATE`, and a health route at `/api/health`.
Both templates were proven against a real app: red before, green after, and a live capture showed nothing private left it.

## Sampling and quota

The free plan has small quotas, so:

- the health endpoint is never traced: the Compose healthcheck polls it every 30 s (the template's `traces_sampler` drops it);
- API traces at 1.0 while traffic is small (`SENTRY_TRACES_SAMPLE_RATE` lowers it), following the browser's decision when a trace comes in from it;
- browser traces at 0.2 in production, 1.0 in development;
- no Session Replay: Sentry stores the visitor's location on every replay, derived from the address the events arrive from (Caddy's `X-Forwarded-For` through a tunnel route), and ignores an empty `user.geo` there (seen on burtur's replays, 21 November 2026); leave `replayIntegration` out and both replay sample rates unset;
- no profiling until something is slow.

## Source maps

Minified browser frames are useless, so uploading source maps is part of the setup, not a later step.

- Vite: `@sentry/vite-plugin` in `vite.config.ts` with `org: 'kvist-nt'`, the `<app>-web` project, `authToken: process.env.SENTRY_AUTH_TOKEN`, release name from `GIT_SHA`, and `sourcemaps.filesToDeleteAfterUpload` so maps are not served.
- Next.js: `withSentryConfig` from `@sentry/nextjs/config` (v11), same token and release.
- Without the token the plugin skips the upload silently; the CI log should say whether it was set.
- Python frames are readable without anything extra.

## Verification, every app

1. `pytest` passes, including the privacy test.
2. A real error from the running app, through a temporary route that raises, appears in Sentry (MCP `search_issues`): show Rogvi its title, message and URL, then remove the route.
3. For browser code, capture what actually leaves: point the DSN at a local fake ingest (a small HTTP server that writes every request body to a file) and grep its output for the private values. The `sentry:sentry-get-started` flow does steps 2 and 3 end to end.
4. After the first production deploy, check one browser issue has readable frames.

When re-running a check after a change, make sure the old server is gone: `next start` forks a `next-server` that keeps the port, and a stale server once made a fixed build look broken.

## Gotchas (SDK versions of November 2026)

- `@sentry/nextjs` / `@sentry/react` 11: `withSentryConfig` moved to `@sentry/nextjs/config`; there is no `enableLogs` option; `sendDefaultPii` is gone in favour of `dataCollection`, whose unnamed categories default to permissive.
- `@sentry/nextjs` 11.11: Next.js's own `http.target` span attribute keeps the query string whatever `dataCollection` says; the scrubber handles it.
- `sentry-sdk` (Python) 2.x: `include_local_variables` defaults to on and `max_request_body_size` to `"medium"`; `send_default_pii=False` does not change either.
- uvicorn's access log reaches Sentry as breadcrumbs and logs unless `uvicorn.access` is ignored.
