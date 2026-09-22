from __future__ import annotations

import asyncio
import json
from collections.abc import Iterable
from typing import Any

from app.middleware.body_limit import RequestBodyLimitMiddleware


def _run_request(
    chunks: Iterable[bytes], *, content_lengths: list[bytes] | None = None, maximum: int = 10
) -> tuple[bool, list[dict[str, Any]]]:
    called = False
    output: list[dict[str, Any]] = []
    list_chunks = list(chunks)
    messages = [
        {"type": "http.request", "body": chunk, "more_body": index < len(list_chunks) - 1}
        for index, chunk in enumerate(list_chunks)
    ]
    headers = [(b"content-length", value) for value in (content_lengths or [])]

    async def receive() -> dict[str, Any]:
        return messages.pop(0)

    async def send(message: dict[str, Any]) -> None:
        output.append(message)

    async def downstream(_scope: dict[str, Any], receive_inner: Any, send_inner: Any) -> None:
        nonlocal called
        called = True
        while True:
            message = await receive_inner()
            if not message.get("more_body", False):
                break
        await send_inner({"type": "http.response.start", "status": 204, "headers": []})
        await send_inner({"type": "http.response.body", "body": b"", "more_body": False})

    middleware = RequestBodyLimitMiddleware(downstream, max_bytes=maximum)
    asyncio.run(
        middleware(
            {"type": "http", "method": "POST", "path": "/v1/analyze", "headers": headers},
            receive,
            send,
        )
    )
    return called, output


def _error_code(output: list[dict[str, Any]]) -> str:
    body = next(message["body"] for message in output if message["type"] == "http.response.body")
    return str(json.loads(body)["error"]["code"])


def test_content_length_rejects_before_downstream_or_multipart_parser() -> None:
    called, output = _run_request([b"not-read"], content_lengths=[b"11"], maximum=10)
    assert called is False
    assert output[0]["status"] == 413
    assert _error_code(output) == "request_body_too_large"


def test_streaming_limit_catches_missing_or_spoofed_content_length() -> None:
    called, output = _run_request([b"123456", b"789012"], content_lengths=[b"5"], maximum=10)
    assert called is True
    assert output[0]["status"] == 413
    assert _error_code(output) == "request_body_too_large"


def test_ambiguous_content_length_is_rejected() -> None:
    called, output = _run_request([b"hello"], content_lengths=[b"5", b"6"], maximum=10)
    assert called is False
    assert output[0]["status"] == 400
    assert _error_code(output) == "invalid_content_length"


def test_body_within_limit_reaches_application() -> None:
    called, output = _run_request([b"hello"], content_lengths=[b"5"], maximum=10)
    assert called is True
    assert output[0]["status"] == 204
