"""
What the API sends to Sentry must not identify users.

Template from the web-app-stack skill (assets/test_sentry_privacy.py).

Runs the real app with the real Sentry options against an in-memory transport,
sends a request full of private data the way Caddy would forward it, and
checks none of it is in anything the SDK tries to send.
"""
import json
import re
import logging

import pytest
import sentry_sdk
from fastapi import Request
from fastapi.testclient import TestClient
from sentry_sdk.transport import Transport

from app.core.sentry import sentry_options
from app.main import app

PRIVATE = [
    "203.0.113.77",  # visitor IP, from X-Forwarded-For / X-Real-IP
    "reprocookie123",
    "reprotoken456",
    "repro@example.com",
    "repro%40example.com",
    "hunter2",  # a password in a request body and a handler's locals
    "chair",  # a search term in the query string
]


class CaptureTransport(Transport):
    def __init__(self, options=None):
        super().__init__(options)
        self.sent: list[str] = []

    def capture_envelope(self, envelope):
        for item in envelope.items:
            self.sent.append(item.payload.get_bytes().decode("utf-8", "replace"))


@pytest.fixture
def captured():
    transport = CaptureTransport()
    sentry_sdk.init(dsn="http://key@localhost/1", transport=transport, **sentry_options())

    async def leaky(request: Request):
        login = await request.json()  # noqa: F841 - a local holding the password
        raise RuntimeError("boom in a login-like handler")

    async def fine():
        return {"ok": True}

    app.add_api_route("/api/_sentry_privacy_probe", leaky, methods=["POST"])
    app.add_api_route("/api/_sentry_privacy_probe", fine, methods=["GET"])
    # Ahead of the SPA fallback, which would otherwise answer these paths.
    app.router.routes[:0] = [app.router.routes.pop(), app.router.routes.pop()]
    try:
        yield transport
    finally:
        del app.router.routes[:2]
        sentry_sdk.get_client().close()
        sentry_sdk.init()  # back to a disabled client for the other tests


def test_nothing_private_reaches_sentry(captured):
    client = TestClient(app, raise_server_exceptions=False, client=("203.0.113.77", 4711))
    headers = {
        "X-Forwarded-For": "203.0.113.77",
        "X-Real-IP": "203.0.113.77",
        "Cookie": "session=reprocookie123",
        "Authorization": "Bearer reprotoken456",
    }
    query = "?email=repro%40example.com&q=chair"
    logging.getLogger("uvicorn.access").info(
        '%s - "GET /api/_sentry_privacy_probe%s HTTP/1.1" 200', "203.0.113.77", query
    )
    assert client.get("/api/_sentry_privacy_probe" + query, headers=headers).status_code == 200
    login = {"email": "repro@example.com", "password": "hunter2"}
    probe = client.post("/api/_sentry_privacy_probe" + query, json=login, headers=headers)
    assert probe.status_code == 500
    sentry_sdk.flush()

    sent = "\n".join(captured.sent)
    assert "boom in a login-like handler" in sent, "the error itself must still be reported"
    leaks = {value: sent.count(value) for value in PRIVATE if value in sent}
    assert not leaks, f"private data sent to Sentry: {leaks}\n{json.dumps(captured.sent)[:3000]}"
    # An empty location, or Sentry fills in a city from the connection.
    assert re.search(r'"geo":\s*\{\}', sent), "the error must carry an empty user.geo"
