"""
Sentry error monitoring and tracing for the API.

Template from the web-app-stack skill (assets/sentry.py). Expects settings
with ENVIRONMENT, SENTRY_DSN (empty disables the SDK), SENTRY_RELEASE and
SENTRY_TRACES_SAMPLE_RATE (1.0).

Call init_sentry() before the FastAPI app is created so the Starlette and
FastAPI integrations (auto-enabled) hook every request.
"""
import re
from typing import Any

import sentry_sdk
from sentry_sdk.integrations.logging import ignore_logger

from app.core.config import settings

# uvicorn's access log line is the client IP plus the full URL, query string
# and all; it says nothing an http.server span does not.
ignore_logger("uvicorn.access")

# Headers that carry the visitor's address (Caddy sets X-Forwarded-For).
_IP_HEADER = re.compile(r"forwarded|-ip$|^remote-|^via$|-user$|^true-client|^cf-connecting", re.I)

# Polled every 10s by the compose healthcheck: tracing it would only burn quota.
_UNTRACED_PATHS = {"/api/health"}


def _traces_sampler(sampling_context: dict[str, Any]) -> float:
    asgi_scope = sampling_context.get("asgi_scope") or {}
    if asgi_scope.get("path") in _UNTRACED_PATHS:
        return 0.0
    parent_sampled = sampling_context.get("parent_sampled")
    if parent_sampled is not None:
        # Follow the frontend's decision so traces stay whole across services.
        return float(parent_sampled)
    return settings.SENTRY_TRACES_SAMPLE_RATE


def _strip_query(url: str) -> str:
    return re.sub(r"[?#].*$", "", url)


def _scrub_request(request: dict[str, Any]) -> None:
    # Query strings carry reset tokens, OAuth codes and what users searched for.
    request.pop("query_string", None)
    request.pop("cookies", None)
    request.pop("env", None)  # REMOTE_ADDR
    request.pop("data", None)  # bodies; max_request_body_size="never" already
    if isinstance(request.get("url"), str):
        request["url"] = _strip_query(request["url"])
    headers = request.get("headers")
    if isinstance(headers, dict):
        for name in [h for h in headers if _IP_HEADER.search(h)]:
            del headers[name]


def _scrub_event(event: dict[str, Any], hint: dict[str, Any]) -> dict[str, Any]:
    """Last check on errors and transactions before they leave for Sentry."""
    if isinstance(event.get("request"), dict):
        _scrub_request(event["request"])
    # Sentry fills in a city from the connection's address unless the event
    # already has a location, whatever the IP settings say. An empty one
    # stores none.
    user = event.get("user") if isinstance(event.get("user"), dict) else {}
    user.pop("ip_address", None)
    user["geo"] = {}
    event["user"] = user
    crumbs = event.get("breadcrumbs")
    for crumb in crumbs.get("values", []) if isinstance(crumbs, dict) else crumbs or []:
        data = crumb.get("data") or {}
        if isinstance(data.get("url"), str):
            data["url"] = _strip_query(data["url"])
        data.pop("http.query", None)
    for span in event.get("spans") or []:
        data = span.get("data") or {}
        data.pop("http.query", None)
        for key in ("url", "url.full", "http.url"):
            if isinstance(data.get(key), str):
                data[key] = _strip_query(data[key])
        if isinstance(span.get("description"), str):
            span["description"] = _strip_query(span["description"])
    return event


def sentry_options() -> dict[str, Any]:
    """Everything but the DSN, so tests can run the same setup."""
    return {
        "environment": settings.ENVIRONMENT,
        "release": settings.SENTRY_RELEASE or None,
        # Keep IPs, cookies and auth headers out of Sentry. Never flip on in
        # production: the privacy rules in the web-app-stack skill.
        "send_default_pii": False,
        # Frame locals hold whole requests (cookies, tokens, client IP) and,
        # in the auth handlers, passwords. Stack traces are enough.
        "include_local_variables": False,
        # Bodies are logins, registrations and messages between users.
        "max_request_body_size": "never",
        "before_send": _scrub_event,
        "before_send_transaction": _scrub_event,
        "traces_sampler": _traces_sampler,
        "enable_logs": True,
    }


def init_sentry() -> None:
    """Start the Sentry SDK; a no-op when SENTRY_DSN is unset."""
    if not settings.SENTRY_DSN:
        return
    sentry_sdk.init(dsn=settings.SENTRY_DSN, **sentry_options())
