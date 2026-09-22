from __future__ import annotations

from datetime import UTC, datetime, timedelta

from app.services.billing import evaluate_subscription


def _iso(delta: timedelta) -> str:
    return (datetime.now(UTC) + delta).isoformat().replace("+00:00", "Z")


def test_active_matching_subscription_is_entitled() -> None:
    result = evaluate_subscription(
        {
            "subscriptionState": "SUBSCRIPTION_STATE_ACTIVE",
            "acknowledgementState": "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED",
            "lineItems": [
                {"productId": "myidealbody_pro_monthly", "expiryTime": _iso(timedelta(days=20))}
            ],
        },
        "myidealbody_pro_monthly",
    )
    assert result.entitlement_active is True
    assert result.expires_at is not None


def test_wrong_product_or_expired_purchase_is_not_entitled() -> None:
    wrong_product = evaluate_subscription(
        {
            "subscriptionState": "SUBSCRIPTION_STATE_ACTIVE",
            "lineItems": [{"productId": "other", "expiryTime": _iso(timedelta(days=20))}],
        },
        "myidealbody_pro_monthly",
    )
    expired = evaluate_subscription(
        {
            "subscriptionState": "SUBSCRIPTION_STATE_CANCELED",
            "lineItems": [
                {"productId": "myidealbody_pro_monthly", "expiryTime": _iso(timedelta(days=-1))}
            ],
        },
        "myidealbody_pro_monthly",
    )
    assert wrong_product.entitlement_active is False
    assert expired.entitlement_active is False


def test_on_hold_subscription_is_not_entitled_even_before_expiry() -> None:
    result = evaluate_subscription(
        {
            "subscriptionState": "SUBSCRIPTION_STATE_ON_HOLD",
            "lineItems": [
                {"productId": "myidealbody_pro_monthly", "expiryTime": _iso(timedelta(days=10))}
            ],
        },
        "myidealbody_pro_monthly",
    )
    assert result.entitlement_active is False
