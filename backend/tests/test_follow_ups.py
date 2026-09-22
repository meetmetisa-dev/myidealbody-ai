from __future__ import annotations

from app.services.analysis import _questions


def test_hidden_ingredient_prompts_cover_oil_santan_and_sugar() -> None:
    questions = _questions({"oil", "coconut_milk", "sugar"}, False, "en")
    assert {question.id for question in questions} == {
        "hidden_oil",
        "hidden_coconut_milk",
        "hidden_sugar",
    }
    assert "santan" in next(question.prompt for question in questions if question.id == "hidden_coconut_milk")


def test_follow_up_prompts_are_localized() -> None:
    questions = _questions({"oil", "coconut_milk", "sugar"}, True, "id")
    assert any("porsi" in question.prompt.lower() for question in questions)
    assert any("santan" in question.prompt.lower() for question in questions)
    assert any("gula" in question.prompt.lower() for question in questions)
