from __future__ import annotations

import io
import os
from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from PIL import Image

os.environ["APP_ENV"] = "development"
os.environ["DEBUG"] = "false"
os.environ["VISION_PROVIDER"] = "mock"
os.environ["BILLING_ENABLED"] = "false"
os.environ["NUTRITION_CATALOG_PATH"] = ""

from app.main import app  # noqa: E402


@pytest.fixture
def client() -> Iterator[TestClient]:
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def jpeg_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (256, 192), color=(205, 170, 100)).save(buffer, format="JPEG")
    return buffer.getvalue()
