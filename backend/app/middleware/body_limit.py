from __future__ import annotations

import json
from collections.abc import Awaitable, Callable
from typing import Any


ASGIMessage = dict[str, Any]
Receive = Callable[[], Awaitable[ASGIMessage]]
Send = Callable[[ASGIMessage], Awaitable[None]]
ASGIApp = Callable[[dict[str, Any], Receive, Send], Awaitable[None]]


class _RequestBodyTooLarge(Exception):
    pass


class RequestBodyLimitMiddleware:
    """Reject oversized bodies before multipart parsing and enforce the streamed total."""

    def __init__(self, app: ASGIApp, max_bytes: int) -> None:
        if max_bytes < 1:
            raise ValueError("max_bytes must be positive")
        self.app = app
        self.max_bytes = max_bytes

    async def _reject(self, send: Send, *, status: int, code: str, message: str) -> None:
        body = json.dumps(
            {"error": {"code": code, "message": message, "details": {}}},
            separators=(",", ":"),
        ).encode("utf-8")
        await send(
            {
                "type": "http.response.start",
                "status": status,
                "headers": [
                    (b"content-type", b"application/json"),
                    (b"content-length", str(len(body)).encode("ascii")),
                ],
            }
        )
        await send({"type": "http.response.body", "body": body, "more_body": False})

    @staticmethod
    def _content_length(scope: dict[str, Any]) -> int | None:
        values = [
            value
            for name, value in scope.get("headers", ())
            if bytes(name).lower() == b"content-length"
        ]
        if not values:
            return None
        try:
            decoded = {bytes(value).decode("ascii").strip() for value in values}
            if len(decoded) != 1:
                raise ValueError
            raw_length = decoded.pop()
            if not raw_length.isdigit():
                raise ValueError
            length = int(raw_length)
            return length
        except (UnicodeDecodeError, ValueError) as exc:
            raise ValueError("Invalid Content-Length header") from exc

    async def __call__(self, scope: dict[str, Any], receive: Receive, send: Send) -> None:
        if scope.get("type") != "http":
            await self.app(scope, receive, send)
            return
        try:
            declared_length = self._content_length(scope)
        except ValueError:
            await self._reject(
                send,
                status=400,
                code="invalid_content_length",
                message="The Content-Length header is invalid or ambiguous.",
            )
            return
        if declared_length is not None and declared_length > self.max_bytes:
            await self._reject(
                send,
                status=413,
                code="request_body_too_large",
                message=f"Request body exceeds the {self.max_bytes}-byte limit.",
            )
            return

        received = 0
        response_started = False

        async def limited_receive() -> ASGIMessage:
            nonlocal received
            message = await receive()
            if message.get("type") == "http.request":
                received += len(message.get("body", b""))
                if received > self.max_bytes:
                    raise _RequestBodyTooLarge
            return message

        async def tracked_send(message: ASGIMessage) -> None:
            nonlocal response_started
            if message.get("type") == "http.response.start":
                response_started = True
            await send(message)

        try:
            await self.app(scope, limited_receive, tracked_send)
        except _RequestBodyTooLarge:
            if response_started:
                raise
            await self._reject(
                send,
                status=413,
                code="request_body_too_large",
                message=f"Request body exceeds the {self.max_bytes}-byte limit.",
            )
