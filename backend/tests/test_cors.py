from __future__ import annotations

from fastapi.testclient import TestClient


def test_github_pages_origin_can_post_an_image(client: TestClient) -> None:
    response = client.options(
        "/v1/analyze",
        headers={
            "Origin": "https://meetmetisa-dev.github.io",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "content-type",
        },
    )

    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "https://meetmetisa-dev.github.io"
    assert "POST" in response.headers["access-control-allow-methods"]


def test_unconfigured_browser_origin_is_not_allowed(client: TestClient) -> None:
    response = client.options(
        "/v1/analyze",
        headers={
            "Origin": "https://attacker.example",
            "Access-Control-Request-Method": "POST",
        },
    )

    assert response.status_code == 400
    assert "access-control-allow-origin" not in response.headers


def test_cors_header_is_present_on_upload_size_error(client: TestClient) -> None:
    response = client.post(
        "/v1/analyze",
        headers={
            "Origin": "https://meetmetisa-dev.github.io",
            "Content-Type": "multipart/form-data; boundary=irrelevant",
            "Content-Length": str(12 * 1024 * 1024),
        },
        content=b"",
    )

    assert response.status_code == 413
    assert response.headers["access-control-allow-origin"] == "https://meetmetisa-dev.github.io"
