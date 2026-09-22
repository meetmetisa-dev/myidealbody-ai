from __future__ import annotations

import json
import unicodedata
from functools import lru_cache
from pathlib import Path

from pydantic import AliasChoices, BaseModel, ConfigDict, Field, model_validator

from app.models import Locale


class LocalizedText(BaseModel):
    model_config = ConfigDict(extra="forbid")

    en: str = Field(min_length=1)
    id: str = Field(min_length=1)

    def for_locale(self, locale: Locale) -> str:
        return self.id if locale == "id" else self.en


class NutrientsPer100g(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    calories_kcal: float = Field(ge=0)
    protein_g: float = Field(ge=0)
    carbs_g: float = Field(ge=0)
    fat_g: float = Field(ge=0)


class Portion(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    id: str
    label: LocalizedText
    grams: float = Field(gt=0, le=3000)


class FoodProvenance(BaseModel):
    model_config = ConfigDict(extra="forbid")

    dataset: str = Field(min_length=1)
    record_id: str = Field(min_length=1)
    license: str = Field(min_length=1)
    retrieved_on: str = Field(min_length=1)


class CatalogFood(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    id: str = Field(pattern=r"^[a-z0-9_]+$")
    name: LocalizedText
    aliases: list[str] = Field(default_factory=list)
    nutrients_per_100g: NutrientsPer100g
    portions: list[Portion] = Field(default_factory=list)
    ambiguity_tags: list[str] = Field(default_factory=list)
    density_g_per_ml: float | None = Field(default=None, gt=0)
    provenance: FoodProvenance | None = None


class CatalogMetadata(BaseModel):
    model_config = ConfigDict(extra="allow")

    version: str = Field(validation_alias=AliasChoices("version", "schema_version"))
    approximate_demo_data: bool
    disclaimer: str | LocalizedText


class CatalogDocument(BaseModel):
    model_config = ConfigDict(extra="forbid")

    metadata: CatalogMetadata
    foods: list[CatalogFood] = Field(min_length=1)

    @model_validator(mode="after")
    def validate_unique_ids(self) -> "CatalogDocument":
        ids = [food.id for food in self.foods]
        if len(ids) != len(set(ids)):
            raise ValueError("Catalog food IDs must be unique")
        return self


def _normalize(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value.casefold().strip())
    return " ".join("".join(ch for ch in normalized if not unicodedata.combining(ch)).split())


class FoodCatalog:
    def __init__(self, document: CatalogDocument) -> None:
        self.document = document
        self.by_id = {food.id: food for food in document.foods}
        aliases: dict[str, str] = {}
        for food in document.foods:
            for alias in (food.id, food.name.en, food.name.id, *food.aliases):
                key = _normalize(alias)
                existing = aliases.get(key)
                if existing is not None and existing != food.id:
                    raise ValueError(f"Duplicate catalog alias: {alias!r}")
                aliases[key] = food.id
        self._aliases = aliases

    @classmethod
    def from_path(cls, path: Path) -> "FoodCatalog":
        payload = json.loads(path.read_text(encoding="utf-8"))
        return cls(CatalogDocument.model_validate(payload))

    @property
    def version(self) -> str:
        return self.document.metadata.version

    def get(self, food_id: str) -> CatalogFood | None:
        return self.by_id.get(food_id)

    def resolve(self, value: str) -> CatalogFood | None:
        food_id = self._aliases.get(_normalize(value))
        return self.by_id.get(food_id) if food_id else None

    def provider_options(self) -> list[dict[str, object]]:
        return [
            {
                "id": food.id,
                "name_en": food.name.en,
                "name_id": food.name.id,
                "example_portions_g": [portion.grams for portion in food.portions[:3]],
            }
            for food in self.document.foods
        ]


@lru_cache(maxsize=1)
def get_catalog() -> FoodCatalog:
    return FoodCatalog.from_path(Path(__file__).with_name("data") / "foods.json")
