#!/usr/bin/env python3
"""Dependency-free repository checks for CI and restricted environments."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []


def require(relative: str) -> Path:
    path = ROOT / relative
    if not path.is_file() or path.stat().st_size == 0:
        ERRORS.append(f"missing or empty required file: {relative}")
    return path


required_files = (
    "README.md",
    "backend/app/main.py",
    "backend/app/data/foods.json",
    "backend/requirements-dev.txt",
    "mobile/pubspec.yaml",
    "mobile/lib/main.dart",
    "mobile/lib/l10n/app_en.arb",
    "mobile/lib/l10n/app_id.arb",
    "mobile/android/app/src/main/AndroidManifest.xml",
    "mobile/android/app/build.gradle.kts",
    "mobile/test/nutrition_models_test.dart",
    "docs/PLAY_STORE_LAUNCH.md",
    "docs/PRIVACY_SECURITY.md",
)
for item in required_files:
    require(item)


def read_json(relative: str) -> dict:
    try:
        value = json.loads((ROOT / relative).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        ERRORS.append(f"invalid JSON in {relative}: {exc}")
        return {}
    if not isinstance(value, dict):
        ERRORS.append(f"expected a JSON object in {relative}")
        return {}
    return value


english = read_json("mobile/lib/l10n/app_en.arb")
indonesian = read_json("mobile/lib/l10n/app_id.arb")
english_keys = {key for key in english if not key.startswith("@")}
indonesian_keys = {key for key in indonesian if not key.startswith("@")}
if english_keys != indonesian_keys:
    ERRORS.append(
        "localization key mismatch: "
        f"English-only={sorted(english_keys - indonesian_keys)}, "
        f"Indonesian-only={sorted(indonesian_keys - english_keys)}"
    )
for key in sorted(english_keys & indonesian_keys):
    english_meta = english.get(f"@{key}", {})
    indonesian_meta = indonesian.get(f"@{key}", {})
    english_placeholders = set(
        english_meta.get("placeholders", {}) if isinstance(english_meta, dict) else {}
    )
    indonesian_placeholders = set(
        indonesian_meta.get("placeholders", {}) if isinstance(indonesian_meta, dict) else {}
    )
    if english_placeholders != indonesian_placeholders:
        ERRORS.append(
            f"localization placeholder mismatch for {key}: "
            f"English={sorted(english_placeholders)}, "
            f"Indonesian={sorted(indonesian_placeholders)}"
        )

catalog = read_json("backend/app/data/foods.json")
foods = catalog.get("foods", [])
metadata = catalog.get("metadata", {})
if not isinstance(foods, list) or len(foods) < 20:
    ERRORS.append("demo food catalog must contain at least 20 foods")
if not isinstance(metadata, dict) or metadata.get("approximate_demo_data") is not True:
    ERRORS.append("demo food catalog must be explicitly marked approximate")
food_ids = [food.get("id") for food in foods if isinstance(food, dict)]
if len(food_ids) != len(set(food_ids)):
    ERRORS.append("demo food catalog contains duplicate IDs")

dart_files = list((ROOT / "mobile/lib").rglob("*.dart"))
nonstandard_weight = re.compile(r"FontWeight\.w(?![1-9]00\b)\d+")
for path in dart_files:
    text = path.read_text(encoding="utf-8")
    if match := nonstandard_weight.search(text):
        ERRORS.append(f"unsupported font weight in {path.relative_to(ROOT)}: {match.group(0)}")
    if re.search(
        r"Widget build\(BuildContext context\)\s*\{\s*Widget build\(BuildContext context\)",
        text,
    ):
        ERRORS.append(f"duplicate build declaration in {path.relative_to(ROOT)}")
    if re.search(r"style:\s*IconButton\.styleFrom\(\s*style:", text):
        ERRORS.append(f"duplicate IconButton style argument in {path.relative_to(ROOT)}")

android_build = ROOT / "mobile/android/app/build.gradle.kts"
if android_build.is_file():
    build_text = android_build.read_text(encoding="utf-8")
    if not re.search(r"targetSdk\s*=\s*36\b", build_text):
        ERRORS.append("Android targetSdk must be 36")
    if not re.search(r"compileSdk\s*=\s*36\b", build_text):
        ERRORS.append("Android compileSdk must be 36")

joined_config = "\n".join(
    path.read_text(encoding="utf-8")
    for path in (
        ROOT / "mobile/lib/core/app_config.dart",
        ROOT / "backend/app/config.py",
    )
    if path.is_file()
)
for product_id in ("myidealbody_pro_monthly", "myidealbody_pro_annual"):
    if joined_config.count(product_id) < 2:
        ERRORS.append(f"subscription product ID is not aligned across client/server: {product_id}")

if ERRORS:
    print("Repository validation failed:", file=sys.stderr)
    for error in ERRORS:
        print(f"- {error}", file=sys.stderr)
    raise SystemExit(1)

print(
    f"Repository validation passed: {len(english_keys)} bilingual strings, "
    f"{len(foods)} demo foods, Android API 36."
)
