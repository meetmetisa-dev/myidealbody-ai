from __future__ import annotations

import pytest
from pydantic import ValidationError

from app.catalog import NutrientsPer100g, get_catalog
from app.providers.base import FoodDetection


def test_demo_catalog_is_explicitly_approximate_and_bilingual() -> None:
    catalog = get_catalog()
    assert catalog.document.metadata.approximate_demo_data is True
    assert len(catalog.document.foods) >= 20
    assert catalog.resolve("nasi") is not None
    assert catalog.resolve("white rice") is not None
    assert all(food.name.en and food.name.id for food in catalog.document.foods)


def test_detection_schema_refuses_provider_supplied_nutrients() -> None:
    with pytest.raises(ValidationError):
        FoodDetection.model_validate(
            {
                "catalog_id": "nasi_putih",
                "estimated_grams": 100,
                "confidence": 0.8,
                "calories": 500,
            }
        )


@pytest.mark.parametrize("bad_value", [float("inf"), float("-inf"), float("nan")])
def test_catalog_rejects_non_finite_nutrients(bad_value: float) -> None:
    with pytest.raises(ValidationError):
        NutrientsPer100g(
            calories_kcal=bad_value,
            protein_g=1,
            carbs_g=1,
            fat_g=1,
        )
