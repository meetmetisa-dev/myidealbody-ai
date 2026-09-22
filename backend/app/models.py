from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, SecretStr


Locale = Literal["en", "id"]


class NutrientRange(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    min: float = Field(ge=0)
    max: float = Field(ge=0)
    estimated: float = Field(ge=0)


class AnalysisTotal(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    calories: NutrientRange
    protein_g: NutrientRange
    carbs_g: NutrientRange
    fat_g: NutrientRange


class FoodEstimate(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    id: str
    name: str
    quantity: float = Field(gt=0)
    unit: Literal["g"] = "g"
    calories: NutrientRange
    protein_g: NutrientRange
    carbs_g: NutrientRange
    fat_g: NutrientRange
    confidence: float = Field(ge=0, le=1)


class FollowUpOption(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    label: str


class FollowUpQuestion(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    type: Literal["single_choice", "portion_confirmation"]
    prompt: str
    options: list[FollowUpOption]


class AnalyzeResponse(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    analysis_id: str
    total: AnalysisTotal
    confidence: float = Field(ge=0, le=1)
    foods: list[FoodEstimate]
    caveats: list[str]
    follow_up_questions: list[FollowUpQuestion]
    provider: str
    catalog_version: str


class HealthResponse(BaseModel):
    status: Literal["ok"] = "ok"
    version: str
    provider: str


class BillingVerifyRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    product_id: str = Field(min_length=3, max_length=200, pattern=r"^[a-zA-Z0-9._-]+$")
    purchase_token: SecretStr = Field(min_length=10, max_length=4096)


class BillingVerifyResponse(BaseModel):
    model_config = ConfigDict(extra="forbid")

    product_id: str
    entitlement_active: bool
    subscription_state: str
    expires_at: datetime | None
    acknowledgement_state: str | None
