from __future__ import annotations

from app.models import Locale
from app.providers.base import FoodDetection, RecognitionProvider, RecognitionResult


class MockRecognitionProvider(RecognitionProvider):
    """Offline provider for development; it does not inspect or identify the image."""

    name = "mock_demo"

    async def recognize(
        self,
        *,
        image: bytes,
        mime_type: str,
        filename: str | None,
        locale: Locale,
    ) -> RecognitionResult:
        del image, mime_type, filename, locale
        return RecognitionResult(
            foods=[
                FoodDetection(catalog_id="nasi_putih", estimated_grams=180, confidence=0.82),
                FoodDetection(catalog_id="ayam_goreng", estimated_grams=100, confidence=0.72),
                FoodDetection(catalog_id="sayur_campur", estimated_grams=80, confidence=0.58),
            ],
            scene_confidence=0.70,
        )
