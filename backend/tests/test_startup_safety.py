from __future__ import annotations

from dataclasses import replace

import pytest

from app.catalog import CatalogDocument, FoodCatalog, FoodProvenance, get_catalog
from app.config import Settings, get_settings
from app.startup import validate_production_configuration


def _production_catalog(*, complete_provenance: bool = True) -> FoodCatalog:
    source = get_catalog().document
    provenance = FoodProvenance(
        dataset="authorized-test-dataset",
        record_id="record-1",
        license="test-license",
        retrieved_on="2026-09-19",
    )
    foods = [
        food.model_copy(update={"provenance": provenance if complete_provenance else None})
        for food in source.foods
    ]
    metadata = source.metadata.model_copy(update={"approximate_demo_data": False})
    return FoodCatalog(CatalogDocument(metadata=metadata, foods=foods))


def _safe_production_settings(**updates: object) -> Settings:
    defaults: dict[str, object] = {
        "app_env": "production",
        "debug": False,
        "provider": "openai_compatible",
        "openai_base_url": "https://vlm.example.com/v1",
        "allow_insecure_private_vlm_http": False,
    }
    defaults.update(updates)
    return replace(get_settings(), **defaults)


def test_safe_production_configuration_passes() -> None:
    validate_production_configuration(_safe_production_settings(), _production_catalog())


@pytest.mark.parametrize(
    ("settings", "message"),
    [
        (_safe_production_settings(debug=True), "DEBUG"),
        (_safe_production_settings(provider="mock"), "VISION_PROVIDER=mock"),
        (
            _safe_production_settings(openai_base_url="http://vlm.example.com/v1"),
            "must use HTTPS",
        ),
        (
            _safe_production_settings(
                openai_base_url="http://vlm.example.com/v1",
                allow_insecure_private_vlm_http=True,
            ),
            "must use HTTPS",
        ),
    ],
)
def test_unsafe_production_settings_fail_closed(settings: Settings, message: str) -> None:
    with pytest.raises(RuntimeError, match=message):
        validate_production_configuration(settings, _production_catalog())


def test_demo_catalog_and_missing_provenance_fail_in_production() -> None:
    with pytest.raises(RuntimeError, match="demo nutrition catalog"):
        validate_production_configuration(_safe_production_settings(), get_catalog())
    with pytest.raises(RuntimeError, match="needs provenance"):
        validate_production_configuration(
            _safe_production_settings(), _production_catalog(complete_provenance=False)
        )


def test_plain_http_override_is_limited_to_private_hosts() -> None:
    settings = _safe_production_settings(
        openai_base_url="http://10.20.30.40:11434/v1",
        allow_insecure_private_vlm_http=True,
    )
    validate_production_configuration(settings, _production_catalog())


def test_development_mode_remains_easy_to_run() -> None:
    validate_production_configuration(get_settings(), get_catalog())


def test_app_env_is_normalized(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("APP_ENV", "  ProDuction  ")
    get_settings.cache_clear()
    try:
        assert get_settings().app_env == "production"
        assert get_settings().is_production is True
    finally:
        get_settings.cache_clear()


def test_unknown_app_env_is_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("APP_ENV", "prodution")
    get_settings.cache_clear()
    try:
        with pytest.raises(ValueError, match="APP_ENV"):
            get_settings()
    finally:
        get_settings.cache_clear()
