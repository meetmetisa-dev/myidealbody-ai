#!/usr/bin/env python3
"""Verify a configured API is a TLS endpoint backed by the real provider."""

from __future__ import annotations

import json
import os
import sys
from urllib.error import HTTPError, URLError
from urllib.request import HTTPRedirectHandler, Request, build_opener


class _NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, request, file_pointer, code, message, headers, new_url):
        return None


def validate_health_payload(payload: object) -> list[str]:
    if not isinstance(payload, dict):
        return ["production health response must be a JSON object"]
    errors: list[str] = []
    if payload.get("status") != "ok":
        errors.append("production health response did not report status=ok")
    if payload.get("provider") != "openai_compatible":
        errors.append("production health response did not report the real provider")
    return errors


def main() -> int:
    base_url = os.environ.get("API_BASE_URL", "").rstrip("/")
    request = Request(
        f"{base_url}/health",
        headers={"Accept": "application/json", "User-Agent": "MyIdealBody-release-check"},
    )
    try:
        with build_opener(_NoRedirect).open(request, timeout=15) as response:
            if response.status != 200:
                raise ValueError("unexpected status")
            raw = response.read(16_385)
            if len(raw) > 16_384:
                raise ValueError("response too large")
            payload = json.loads(raw)
    except (HTTPError, URLError, OSError, ValueError, json.JSONDecodeError):
        print(
            "Production API health verification failed without exposing the configured URL.",
            file=sys.stderr,
        )
        return 1

    errors = validate_health_payload(payload)
    if errors:
        print("Production API health verification failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("Production API health verification passed with the real provider.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
