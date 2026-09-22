from __future__ import annotations

from collections import defaultdict
from uuid import uuid4

from app.catalog import CatalogFood, FoodCatalog
from app.errors import AppError
from app.models import (
    AnalysisTotal,
    AnalyzeResponse,
    FoodEstimate,
    FollowUpOption,
    FollowUpQuestion,
    Locale,
    NutrientRange,
)
from app.providers.base import RecognitionProvider


_NUTRIENT_ATTRS = {
    "calories": "calories_kcal",
    "protein_g": "protein_g",
    "carbs_g": "carbs_g",
    "fat_g": "fat_g",
}


def _rounded(value: float, nutrient: str) -> float:
    return float(round(value)) if nutrient == "calories" else round(value, 1)


def _nutrient_range(value: float, confidence: float, nutrient: str) -> NutrientRange:
    # Even high visual confidence cannot make single-photo portion sizing exact.
    relative_uncertainty = min(0.60, max(0.18, 0.18 + (1.0 - confidence) * 0.42))
    return NutrientRange(
        min=_rounded(max(0, value * (1 - relative_uncertainty)), nutrient),
        max=_rounded(value * (1 + relative_uncertainty), nutrient),
        estimated=_rounded(value, nutrient),
    )


def _food_estimate(food: CatalogFood, grams: float, confidence: float, locale: Locale) -> FoodEstimate:
    factor = grams / 100.0
    values = {
        output_name: getattr(food.nutrients_per_100g, catalog_name) * factor
        for output_name, catalog_name in _NUTRIENT_ATTRS.items()
    }
    return FoodEstimate(
        id=food.id,
        name=food.name.for_locale(locale),
        quantity=round(grams),
        calories=_nutrient_range(values["calories"], confidence, "calories"),
        protein_g=_nutrient_range(values["protein_g"], confidence, "protein_g"),
        carbs_g=_nutrient_range(values["carbs_g"], confidence, "carbs_g"),
        fat_g=_nutrient_range(values["fat_g"], confidence, "fat_g"),
        confidence=round(confidence, 2),
    )


def _sum_range(foods: list[FoodEstimate], field: str) -> NutrientRange:
    values = [getattr(food, field) for food in foods]
    nutrient = "calories" if field == "calories" else field
    return NutrientRange(
        min=_rounded(sum(item.min for item in values), nutrient),
        max=_rounded(sum(item.max for item in values), nutrient),
        estimated=_rounded(sum(item.estimated for item in values), nutrient),
    )


def _option(option_id: str, en: str, id_text: str, locale: Locale) -> FollowUpOption:
    return FollowUpOption(id=option_id, label=id_text if locale == "id" else en)


def _questions(tags: set[str], low_confidence: bool, locale: Locale) -> list[FollowUpQuestion]:
    questions: list[FollowUpQuestion] = []
    if low_confidence:
        questions.append(
            FollowUpQuestion(
                id="confirm_portion",
                type="portion_confirmation",
                prompt=(
                    "Apakah perkiraan ukuran porsinya sudah benar?"
                    if locale == "id"
                    else "Does the estimated portion size look right?"
                ),
                options=[
                    _option("smaller", "Smaller", "Lebih kecil", locale),
                    _option("correct", "Looks right", "Sudah sesuai", locale),
                    _option("larger", "Larger", "Lebih besar", locale),
                ],
            )
        )
    if "oil" in tags:
        questions.append(
            FollowUpQuestion(
                id="hidden_oil",
                type="single_choice",
                prompt=(
                    "Berapa banyak minyak atau mentega tambahan yang digunakan?"
                    if locale == "id"
                    else "How much added oil or butter was used?"
                ),
                options=[
                    _option("none", "None", "Tidak ada", locale),
                    _option("one_tsp", "About 1 teaspoon", "Sekitar 1 sendok teh", locale),
                    _option("one_tbsp", "About 1 tablespoon", "Sekitar 1 sendok makan", locale),
                    _option("unknown", "Not sure", "Tidak yakin", locale),
                ],
            )
        )
    if "coconut_milk" in tags:
        questions.append(
            FollowUpQuestion(
                id="hidden_coconut_milk",
                type="single_choice",
                prompt=(
                    "Apakah hidangan ini memakai santan?"
                    if locale == "id"
                    else "Was coconut milk (santan) used in this dish?"
                ),
                options=[
                    _option("none", "No", "Tidak", locale),
                    _option("light", "A little / diluted", "Sedikit / encer", locale),
                    _option("rich", "A rich amount", "Banyak / kental", locale),
                    _option("unknown", "Not sure", "Tidak yakin", locale),
                ],
            )
        )
    if "sugar" in tags:
        questions.append(
            FollowUpQuestion(
                id="hidden_sugar",
                type="single_choice",
                prompt=(
                    "Berapa banyak gula atau sirup tambahan?"
                    if locale == "id"
                    else "How much added sugar or syrup was used?"
                ),
                options=[
                    _option("none", "None", "Tidak ada", locale),
                    _option("one_tsp", "About 1 teaspoon", "Sekitar 1 sendok teh", locale),
                    _option("one_tbsp", "About 1 tablespoon", "Sekitar 1 sendok makan", locale),
                    _option("unknown", "Not sure", "Tidak yakin", locale),
                ],
            )
        )
    return questions


class AnalysisService:
    def __init__(self, *, provider: RecognitionProvider, catalog: FoodCatalog) -> None:
        self.provider = provider
        self.catalog = catalog

    async def analyze(
        self,
        *,
        image: bytes,
        mime_type: str,
        filename: str | None,
        locale: Locale,
    ) -> AnalyzeResponse:
        recognition = await self.provider.recognize(
            image=image,
            mime_type=mime_type,
            filename=filename,
            locale=locale,
        )
        grouped_grams: dict[str, float] = defaultdict(float)
        weighted_confidence: dict[str, float] = defaultdict(float)
        for detected in recognition.foods:
            if self.catalog.get(detected.catalog_id) is None:
                continue
            grouped_grams[detected.catalog_id] += detected.estimated_grams
            weighted_confidence[detected.catalog_id] += detected.confidence * detected.estimated_grams

        foods: list[FoodEstimate] = []
        ambiguity_tags: set[str] = set()
        for food_id, grams in grouped_grams.items():
            catalog_food = self.catalog.get(food_id)
            if catalog_food is None:
                continue
            confidence = weighted_confidence[food_id] / grams
            foods.append(_food_estimate(catalog_food, grams, confidence, locale))
            ambiguity_tags.update(catalog_food.ambiguity_tags)

        if not foods:
            raise AppError(
                code="no_food_detected",
                message=(
                    "Makanan tidak terdeteksi. Coba foto ulang dengan pencahayaan yang lebih baik."
                    if locale == "id"
                    else "No supported food was detected. Try another photo with better lighting."
                ),
                status_code=422,
            )

        weighted_scene = sum(food.confidence * food.quantity for food in foods) / sum(
            food.quantity for food in foods
        )
        overall_confidence = min(0.88, (weighted_scene + recognition.scene_confidence) / 2)
        low_confidence = overall_confidence < 0.72 or any(food.confidence < 0.62 for food in foods)
        caveats = (
            [
                "Ini adalah perkiraan, bukan pengukuran medis.",
                "Minyak, santan, gula, dan bahan tersembunyi mungkin tidak terlihat di foto.",
                "Data gizi demo bersifat perkiraan; periksa dan koreksi makanan serta porsinya.",
            ]
            if locale == "id"
            else [
                "This is an estimate, not a medical measurement.",
                "Oil, coconut milk, sugar, and other hidden ingredients may not be visible.",
                "Demo nutrition data is approximate; review and correct foods and portions.",
            ]
        )
        if not self.catalog.document.metadata.approximate_demo_data:
            caveats[-1] = (
                "Nilai gizi tetap dapat berubah menurut resep, merek, dan cara memasak."
                if locale == "id"
                else "Nutrition values can still vary by recipe, brand, and cooking method."
            )
        return AnalyzeResponse(
            analysis_id=str(uuid4()),
            total=AnalysisTotal(
                calories=_sum_range(foods, "calories"),
                protein_g=_sum_range(foods, "protein_g"),
                carbs_g=_sum_range(foods, "carbs_g"),
                fat_g=_sum_range(foods, "fat_g"),
            ),
            confidence=round(overall_confidence, 2),
            foods=foods,
            caveats=caveats,
            follow_up_questions=_questions(ambiguity_tags, low_confidence, locale),
            provider=self.provider.name,
            catalog_version=self.catalog.version,
        )
