from __future__ import annotations

import os
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path


def _as_bool(name: str, default: bool = False) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _as_int(name: str, default: int) -> int:
    value = os.getenv(name)
    if value is None:
        return default
    try:
        return int(value)
    except ValueError as exc:
        raise ValueError(f"{name} must be an integer") from exc


def _csv(name: str, default: tuple[str, ...] = ()) -> tuple[str, ...]:
    raw = os.getenv(name)
    if not raw:
        return default
    return tuple(part.strip() for part in raw.split(",") if part.strip())


@dataclass(frozen=True, slots=True)
class Settings:
    app_name: str
    app_env: str
    debug: bool
    api_prefix: str
    cors_origins: tuple[str, ...]
    provider: str
    nutrition_catalog_path: Path | None
    max_upload_bytes: int
    max_request_body_bytes: int
    max_image_pixels: int
    openai_base_url: str
    openai_api_key: str | None
    openai_model: str
    openai_timeout_seconds: int
    allow_insecure_private_vlm_http: bool
    billing_enabled: bool
    billing_internal_bearer_token: str | None
    google_play_package_name: str | None
    google_play_service_account_file: Path | None
    google_play_product_ids: tuple[str, ...]

    @property
    def is_production(self) -> bool:
        return self.app_env.lower() == "production"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    service_account = os.getenv("GOOGLE_PLAY_SERVICE_ACCOUNT_FILE")
    nutrition_catalog = os.getenv("NUTRITION_CATALOG_PATH")
    max_upload_bytes = _as_int("MAX_UPLOAD_BYTES", 10 * 1024 * 1024)
    settings = Settings(
        app_name=os.getenv("APP_NAME", "MyIdealBody AI API"),
        app_env=os.getenv("APP_ENV", "development").strip().lower(),
        debug=_as_bool("DEBUG", False),
        api_prefix=os.getenv("API_PREFIX", "/v1").rstrip("/"),
        cors_origins=_csv(
            "CORS_ORIGINS",
            ("http://localhost:3000", "http://localhost:5173"),
        ),
        provider=os.getenv("VISION_PROVIDER", "mock").strip().lower(),
        nutrition_catalog_path=Path(nutrition_catalog) if nutrition_catalog else None,
        max_upload_bytes=max_upload_bytes,
        max_request_body_bytes=_as_int(
            "MAX_REQUEST_BODY_BYTES", max_upload_bytes + 1024 * 1024
        ),
        max_image_pixels=_as_int("MAX_IMAGE_PIXELS", 25_000_000),
        openai_base_url=os.getenv("OPENAI_COMPATIBLE_BASE_URL", "http://localhost:11434/v1").rstrip("/"),
        openai_api_key=os.getenv("OPENAI_COMPATIBLE_API_KEY"),
        openai_model=os.getenv("OPENAI_COMPATIBLE_MODEL", "qwen2.5-vl:7b"),
        openai_timeout_seconds=_as_int("OPENAI_COMPATIBLE_TIMEOUT_SECONDS", 45),
        allow_insecure_private_vlm_http=_as_bool("ALLOW_INSECURE_PRIVATE_VLM_HTTP", False),
        billing_enabled=_as_bool("BILLING_ENABLED", False),
        billing_internal_bearer_token=os.getenv("BILLING_INTERNAL_BEARER_TOKEN"),
        google_play_package_name=os.getenv("GOOGLE_PLAY_PACKAGE_NAME"),
        google_play_service_account_file=Path(service_account) if service_account else None,
        google_play_product_ids=_csv(
            "GOOGLE_PLAY_PRODUCT_IDS",
            ("myidealbody_pro_monthly", "myidealbody_pro_annual"),
        ),
    )
    if settings.app_env not in {"development", "test", "production"}:
        raise ValueError("APP_ENV must be 'development', 'test', or 'production'")
    if settings.provider not in {"mock", "openai_compatible"}:
        raise ValueError("VISION_PROVIDER must be 'mock' or 'openai_compatible'")
    if settings.max_upload_bytes < 1:
        raise ValueError("MAX_UPLOAD_BYTES must be positive")
    if settings.max_request_body_bytes < 1:
        raise ValueError("MAX_REQUEST_BODY_BYTES must be positive")
    if settings.max_image_pixels < 1:
        raise ValueError("MAX_IMAGE_PIXELS must be positive")
    if settings.openai_timeout_seconds < 1:
        raise ValueError("OPENAI_COMPATIBLE_TIMEOUT_SECONDS must be positive")
    if settings.api_prefix and not settings.api_prefix.startswith("/"):
        raise ValueError("API_PREFIX must be empty or begin with '/'")
    if (
        settings.billing_enabled
        and settings.billing_internal_bearer_token
        and len(settings.billing_internal_bearer_token) < 32
    ):
        raise ValueError("BILLING_INTERNAL_BEARER_TOKEN must be at least 32 characters")
    return settings
