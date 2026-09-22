from __future__ import annotations

import pytest

from pydantic import ValidationError

from app.providers.base import ProviderError, RecognitionResult
from app.providers.openai_compatible import _extract_json


def test_extracts_plain_or_fenced_json() -> None:
    assert _extract_json('{"foods":[],"scene_confidence":0.2}')["scene_confidence"] == 0.2
    assert _extract_json('```json\n{"foods":[],"scene_confidence":0.4}\n```')[
        "scene_confidence"
    ] == 0.4


def test_rejects_non_json_provider_content() -> None:
    with pytest.raises(ProviderError):
        _extract_json("I think that is rice")


def test_extracts_supported_text_content_array() -> None:
    parsed = _extract_json(
        [{"type": "text", "text": '{"foods":[],'}, {"type": "output_text", "text": '"scene_confidence":0.4}'}]
    )
    assert parsed["scene_confidence"] == 0.4


@pytest.mark.parametrize("content", [None, {"text": "{}"}, [42], [{"type": "image", "url": "x"}]])
def test_rejects_unsupported_or_non_text_message_content(content: object) -> None:
    with pytest.raises(ProviderError):
        _extract_json(content)


def test_non_finite_provider_number_is_rejected() -> None:
    parsed = _extract_json(
        '{"foods":[{"catalog_id":"nasi_putih","estimated_grams":1e999,'
        '"confidence":0.8}],"scene_confidence":0.8}'
    )
    with pytest.raises(ValidationError):
        RecognitionResult.model_validate(parsed)
