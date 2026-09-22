from __future__ import annotations

from fastapi.testclient import TestClient


def test_health(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "version": "0.1.0", "provider": "mock_demo"}


def test_analyze_returns_catalog_calculated_ranges(client: TestClient, jpeg_bytes: bytes) -> None:
    response = client.post(
        "/v1/analyze",
        files={"image": ("meal.jpg", jpeg_bytes, "image/jpeg")},
        data={"locale": "en", "source": "camera"},
    )
    assert response.status_code == 200, response.text
    payload = response.json()
    assert payload["provider"] == "mock_demo"
    assert payload["catalog_version"] == "1.0.0"
    assert [food["id"] for food in payload["foods"]] == [
        "nasi_putih",
        "ayam_goreng",
        "sayur_campur",
    ]
    assert payload["total"]["calories"]["min"] < payload["total"]["calories"]["estimated"]
    assert payload["total"]["calories"]["estimated"] < payload["total"]["calories"]["max"]
    assert payload["total"]["protein_g"]["estimated"] > 0
    assert payload["confidence"] <= 0.88
    assert "hidden_oil" in {question["id"] for question in payload["follow_up_questions"]}
    assert any("approximate" in caveat.lower() for caveat in payload["caveats"])


def test_analyze_localizes_indonesian_output(client: TestClient, jpeg_bytes: bytes) -> None:
    response = client.post(
        "/v1/analyze",
        files={"image": ("makanan.jpg", jpeg_bytes, "image/jpeg")},
        data={"locale": "id", "source": "gallery"},
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["foods"][0]["name"] == "Nasi putih"
    assert any("perkiraan" in caveat.lower() for caveat in payload["caveats"])
    oil_question = next(item for item in payload["follow_up_questions"] if item["id"] == "hidden_oil")
    assert "minyak" in oil_question["prompt"].lower()


def test_rejects_file_larger_than_limit(client: TestClient) -> None:
    response = client.post(
        "/v1/analyze",
        files={"image": ("huge.jpg", b"x" * (10 * 1024 * 1024 + 1), "image/jpeg")},
        data={"locale": "en"},
    )
    assert response.status_code == 413
    assert response.json()["error"]["code"] == "upload_too_large"


def test_rejects_invalid_image(client: TestClient) -> None:
    response = client.post(
        "/v1/analyze",
        files={"image": ("fake.jpg", b"not really an image", "image/jpeg")},
        data={"locale": "en"},
    )
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "invalid_image"


def test_rejects_mismatched_mime_type(client: TestClient, jpeg_bytes: bytes) -> None:
    response = client.post(
        "/v1/analyze",
        files={"image": ("meal.png", jpeg_bytes, "image/png")},
        data={"locale": "en"},
    )
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "image_type_mismatch"


def test_validation_error_has_stable_shape(client: TestClient, jpeg_bytes: bytes) -> None:
    response = client.post(
        "/v1/analyze",
        files={"image": ("meal.jpg", jpeg_bytes, "image/jpeg")},
        data={"locale": "fr"},
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_error"


def test_billing_verification_is_disabled_by_default(client: TestClient) -> None:
    response = client.post(
        "/v1/billing/google/verify",
        json={"product_id": "myidealbody_pro_monthly", "purchase_token": "a-valid-looking-token"},
    )
    assert response.status_code == 503
    assert response.json()["error"]["code"] == "billing_disabled"
