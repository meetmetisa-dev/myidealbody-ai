from __future__ import annotations

import base64
import io
import json
import re
from typing import Any

import httpx
from PIL import Image, ImageOps
from pydantic import ValidationError

from app.catalog import FoodCatalog
from app.config import Settings
from app.models import Locale
from app.providers.base import ProviderError, RecognitionProvider, RecognitionResult


def _prepare_image(image: bytes) -> tuple[bytes, str]:
    """Resize before an external call to limit latency, cost, and data disclosure."""
    with Image.open(io.BytesIO(image)) as source:
        prepared = ImageOps.exif_transpose(source)
        prepared.thumbnail((1600, 1600))
        if prepared.mode not in {"RGB", "L"}:
            background = Image.new("RGB", prepared.size, "white")
            if "A" in prepared.getbands():
                background.paste(prepared, mask=prepared.getchannel("A"))
            else:
                background.paste(prepared)
            prepared = background
        elif prepared.mode == "L":
            prepared = prepared.convert("RGB")
        output = io.BytesIO()
        prepared.save(output, format="JPEG", quality=85, optimize=True)
        return output.getvalue(), "image/jpeg"


def _extract_json(content: object) -> dict[str, Any]:
    if isinstance(content, list):
        text_parts: list[str] = []
        for block in content:
            if not isinstance(block, dict) or block.get("type") not in {"text", "output_text"}:
                raise ProviderError("Vision provider returned an unsupported content block")
            text = block.get("text")
            if not isinstance(text, str):
                raise ProviderError("Vision provider returned a non-text content block")
            text_parts.append(text)
        content = "".join(text_parts)
    if not isinstance(content, str):
        raise ProviderError("Vision provider message content must be text")
    stripped = content.strip()
    fenced = re.fullmatch(r"```(?:json)?\s*(.*?)\s*```", stripped, flags=re.DOTALL | re.IGNORECASE)
    if fenced:
        stripped = fenced.group(1)
    try:
        parsed = json.loads(stripped)
    except json.JSONDecodeError as exc:
        raise ProviderError("Vision provider returned malformed JSON") from exc
    if not isinstance(parsed, dict):
        raise ProviderError("Vision provider response must be a JSON object")
    return parsed


class OpenAICompatibleRecognitionProvider(RecognitionProvider):
    name = "openai_compatible"

    def __init__(self, *, settings: Settings, catalog: FoodCatalog) -> None:
        self.settings = settings
        self.catalog = catalog

    async def recognize(
        self,
        *,
        image: bytes,
        mime_type: str,
        filename: str | None,
        locale: Locale,
    ) -> RecognitionResult:
        del mime_type, filename
        try:
            prepared, prepared_mime = _prepare_image(image)
        except (OSError, ValueError) as exc:
            raise ProviderError("The validated image could not be prepared for recognition") from exc
        data_url = f"data:{prepared_mime};base64,{base64.b64encode(prepared).decode('ascii')}"
        options = json.dumps(self.catalog.provider_options(), ensure_ascii=False, separators=(",", ":"))
        prompt = (
            "Identify the visible foods and estimate edible portion weight in grams. "
            "Use only a catalog_id from the supplied catalog. Return at most 8 foods. "
            "Never calculate or return calories, protein, carbohydrates, fat, or any nutrient. "
            "Lower confidence when the food or portion is uncertain. "
            "Return exactly one JSON object matching: "
            '{"foods":[{"catalog_id":"id","estimated_grams":100,"confidence":0.7}],'
            '"scene_confidence":0.7}. '
            f"User locale: {locale}. Catalog: {options}"
        )
        headers = {"Content-Type": "application/json"}
        if self.settings.openai_api_key:
            headers["Authorization"] = f"Bearer {self.settings.openai_api_key}"
        payload = {
            "model": self.settings.openai_model,
            "temperature": 0,
            "max_tokens": 700,
            "response_format": {"type": "json_object"},
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {"type": "image_url", "image_url": {"url": data_url}},
                    ],
                }
            ],
        }
        try:
            async with httpx.AsyncClient(timeout=self.settings.openai_timeout_seconds) as client:
                response = await client.post(
                    f"{self.settings.openai_base_url}/chat/completions",
                    headers=headers,
                    json=payload,
                )
                response.raise_for_status()
                body = response.json()
            content = body["choices"][0]["message"]["content"]
            result = RecognitionResult.model_validate(_extract_json(content))
        except (httpx.HTTPError, KeyError, IndexError, TypeError, ValueError, ValidationError) as exc:
            raise ProviderError("Vision provider request failed or returned an invalid schema") from exc

        unknown = [food.catalog_id for food in result.foods if self.catalog.get(food.catalog_id) is None]
        if unknown:
            raise ProviderError("Vision provider returned food IDs outside the server catalog")
        return result
