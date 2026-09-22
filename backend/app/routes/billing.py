from __future__ import annotations

import hmac
from typing import Annotated, cast

from fastapi import APIRouter, Header, Request

from app.config import get_settings
from app.errors import AppError
from app.models import BillingVerifyRequest, BillingVerifyResponse
from app.services.billing import GooglePlayVerifier


router = APIRouter(prefix="/billing/google", tags=["billing"])


def _authorize(authorization: str | None) -> None:
    settings = get_settings()
    if not settings.billing_enabled:
        raise AppError(
            code="billing_disabled",
            message="Server-side billing verification is disabled.",
            status_code=503,
        )
    expected = settings.billing_internal_bearer_token
    if not expected:
        raise AppError(
            code="billing_auth_not_configured",
            message="Billing verification authentication is not configured.",
            status_code=503,
        )
    prefix = "Bearer "
    provided = authorization[len(prefix) :] if authorization and authorization.startswith(prefix) else ""
    if not provided or not hmac.compare_digest(provided, expected):
        raise AppError(
            code="unauthorized",
            message="Valid server authentication is required.",
            status_code=401,
        )


@router.post("/verify", response_model=BillingVerifyResponse)
async def verify_google_play_subscription(
    payload: BillingVerifyRequest,
    request: Request,
    authorization: Annotated[str | None, Header()] = None,
) -> BillingVerifyResponse:
    _authorize(authorization)
    verifier = cast(GooglePlayVerifier, request.app.state.billing_verifier)
    return await verifier.verify(
        product_id=payload.product_id,
        purchase_token=payload.purchase_token.get_secret_value(),
    )
