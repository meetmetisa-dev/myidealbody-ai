from __future__ import annotations

import asyncio
from datetime import UTC, datetime
from typing import Any
from urllib.parse import quote

import httpx

from app.config import Settings
from app.errors import AppError
from app.models import BillingVerifyResponse


ANDROID_PUBLISHER_SCOPE = "https://www.googleapis.com/auth/androidpublisher"
ENTITLED_STATES = {
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
    # A canceled subscription normally remains entitled until its paid expiry.
    "SUBSCRIPTION_STATE_CANCELED",
}


def _parse_time(value: object) -> datetime | None:
    if not isinstance(value, str) or not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone(UTC)
    except ValueError:
        return None


def evaluate_subscription(payload: dict[str, Any], expected_product_id: str) -> BillingVerifyResponse:
    state = str(payload.get("subscriptionState") or "SUBSCRIPTION_STATE_UNSPECIFIED")
    acknowledgement = payload.get("acknowledgementState")
    matching_expiries: list[datetime] = []
    for item in payload.get("lineItems") or []:
        if not isinstance(item, dict) or item.get("productId") != expected_product_id:
            continue
        expiry = _parse_time(item.get("expiryTime"))
        if expiry is not None:
            matching_expiries.append(expiry)
    expiry = max(matching_expiries) if matching_expiries else None
    now = datetime.now(UTC)
    entitled = bool(expiry and expiry > now and state in ENTITLED_STATES)
    return BillingVerifyResponse(
        product_id=expected_product_id,
        entitlement_active=entitled,
        subscription_state=state,
        expires_at=expiry,
        acknowledgement_state=str(acknowledgement) if acknowledgement is not None else None,
    )


class GooglePlayVerifier:
    """Read-only verifier for Google Play subscriptionsv2 purchase tokens."""

    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    async def _access_token(self) -> str:
        path = self.settings.google_play_service_account_file
        if path is None or not path.is_file():
            raise AppError(
                code="billing_not_configured",
                message="Google Play verification credentials are not configured.",
                status_code=503,
            )
        try:
            from google.auth.transport.requests import Request as GoogleAuthRequest
            from google.oauth2 import service_account
        except ImportError as exc:
            raise AppError(
                code="billing_dependency_missing",
                message="The server billing verifier dependency is unavailable.",
                status_code=503,
            ) from exc

        def refresh() -> str:
            credentials = service_account.Credentials.from_service_account_file(
                str(path), scopes=[ANDROID_PUBLISHER_SCOPE]
            )
            credentials.refresh(GoogleAuthRequest())
            if not credentials.token:
                raise RuntimeError("Google credentials returned no access token")
            return str(credentials.token)

        try:
            return await asyncio.to_thread(refresh)
        except AppError:
            raise
        except Exception as exc:
            raise AppError(
                code="billing_credentials_failed",
                message="Google Play verification credentials could not be used.",
                status_code=503,
            ) from exc

    async def verify(self, *, product_id: str, purchase_token: str) -> BillingVerifyResponse:
        package_name = self.settings.google_play_package_name
        if not package_name:
            raise AppError(
                code="billing_not_configured",
                message="The Google Play package name is not configured.",
                status_code=503,
            )
        if product_id not in self.settings.google_play_product_ids:
            raise AppError(
                code="unknown_product",
                message="This product is not in the server allowlist.",
                status_code=400,
            )
        token = await self._access_token()
        url = (
            "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/"
            f"{quote(package_name, safe='.')}/purchases/subscriptionsv2/tokens/"
            f"{quote(purchase_token, safe='')}"
        )
        try:
            async with httpx.AsyncClient(timeout=15) as client:
                response = await client.get(url, headers={"Authorization": f"Bearer {token}"})
            if response.status_code in {400, 404}:
                raise AppError(
                    code="invalid_purchase_token",
                    message="Google Play did not recognize this purchase token.",
                    status_code=400,
                )
            response.raise_for_status()
            payload = response.json()
        except AppError:
            raise
        except (httpx.HTTPError, ValueError) as exc:
            raise AppError(
                code="billing_provider_unavailable",
                message="Google Play verification is temporarily unavailable.",
                status_code=502,
            ) from exc
        if not isinstance(payload, dict):
            raise AppError(
                code="billing_provider_invalid_response",
                message="Google Play returned an unexpected response.",
                status_code=502,
            )
        return evaluate_subscription(payload, product_id)
