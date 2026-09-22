from __future__ import annotations

from abc import ABC, abstractmethod

from pydantic import BaseModel, ConfigDict, Field

from app.models import Locale


class FoodDetection(BaseModel):
    """A visual estimate only. Nutrient values are deliberately not accepted here."""

    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    catalog_id: str = Field(pattern=r"^[a-z0-9_]+$")
    estimated_grams: float = Field(ge=1, le=3000)
    confidence: float = Field(ge=0, le=1)


class RecognitionResult(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    foods: list[FoodDetection] = Field(default_factory=list, max_length=12)
    scene_confidence: float = Field(ge=0, le=1)


class RecognitionProvider(ABC):
    name: str

    @abstractmethod
    async def recognize(
        self,
        *,
        image: bytes,
        mime_type: str,
        filename: str | None,
        locale: Locale,
    ) -> RecognitionResult:
        raise NotImplementedError


class ProviderError(RuntimeError):
    """Raised when a recognition provider fails or returns an invalid response."""
