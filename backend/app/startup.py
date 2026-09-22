from __future__ import annotations

import ipaddress
from urllib.parse import urlparse

from app.catalog import FoodCatalog
from app.config import Settings


def _private_http_host(hostname: str | None) -> bool:
    if not hostname:
        return False
    normalized = hostname.rstrip(".").casefold()
    if normalized == "localhost" or normalized.endswith((".localhost", ".local", ".internal")):
        return True
    try:
        address = ipaddress.ip_address(normalized)
    except ValueError:
        return False
    return address.is_private or address.is_loopback or address.is_link_local


def validate_production_configuration(settings: Settings, catalog: FoodCatalog) -> None:
    """Reject configurations that could publish a demo or unsafe transport by accident."""
    if not settings.is_production:
        return

    problems: list[str] = []
    if settings.debug:
        problems.append("DEBUG must be false")
    if settings.provider == "mock":
        problems.append("VISION_PROVIDER=mock is forbidden")
    if catalog.document.metadata.approximate_demo_data:
        problems.append("the approximate demo nutrition catalog is forbidden")
    missing_provenance = [food.id for food in catalog.document.foods if food.provenance is None]
    if missing_provenance:
        preview = ", ".join(missing_provenance[:5])
        suffix = "..." if len(missing_provenance) > 5 else ""
        problems.append(f"every production food needs provenance (missing: {preview}{suffix})")

    if settings.provider == "openai_compatible":
        parsed = urlparse(settings.openai_base_url)
        secure = parsed.scheme.casefold() == "https" and bool(parsed.hostname)
        explicitly_allowed_private_http = (
            parsed.scheme.casefold() == "http"
            and settings.allow_insecure_private_vlm_http
            and _private_http_host(parsed.hostname)
        )
        if not secure and not explicitly_allowed_private_http:
            problems.append(
                "OPENAI_COMPATIBLE_BASE_URL must use HTTPS; plain HTTP is allowed only "
                "with ALLOW_INSECURE_PRIVATE_VLM_HTTP=true and a private/loopback host"
            )

    if problems:
        raise RuntimeError("Unsafe production configuration: " + "; ".join(problems))
