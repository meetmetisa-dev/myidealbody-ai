#!/usr/bin/env python3
"""Dependency-free repository checks for CI and restricted environments."""

from __future__ import annotations

import json
import re
import struct
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
    ".github/workflows/build-play-aab.yml",
    ".github/workflows/lock-flutter-dependencies.yml",
    "scripts/validate_play_release.py",
    "scripts/check_production_health.py",
    "website/privacy.html",
    "website/terms.html",
    "website/support.html",
    "docs/play-store/LISTING_COPY_EN_ID.md",
    "docs/play-store/NEW_PERSONAL_ACCOUNT_CHECKLIST.md",
    "docs/play-store/DATA_SAFETY_DRAFT.md",
    "docs/play-store/HEALTH_APPS_DECLARATION_DRAFT.md",
    "docs/play-store/PRIVACY_PROVIDER_CHECKLIST.md",
    "store_assets/play-icon-512.png",
    "store_assets/feature-graphic-1024x500.png",
)
for item in required_files:
    require(item)


def validate_png(
    relative: str,
    *,
    width: int,
    height: int,
    color_type: int,
    maximum_bytes: int,
) -> None:
    path = ROOT / relative
    try:
        data = path.read_bytes()
    except OSError:
        return
    if len(data) > maximum_bytes:
        ERRORS.append(f"{relative} exceeds the Play asset size limit")
    if len(data) < 33 or data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR":
        ERRORS.append(f"{relative} is not a valid PNG with an IHDR header")
        return
    actual_width, actual_height, bit_depth, actual_color_type = struct.unpack(
        ">IIBB", data[16:26]
    )
    if (actual_width, actual_height) != (width, height):
        ERRORS.append(
            f"{relative} must be {width}x{height}, got "
            f"{actual_width}x{actual_height}"
        )
    if bit_depth != 8 or actual_color_type != color_type:
        ERRORS.append(
            f"{relative} must use 8-bit PNG color type {color_type}, got "
            f"bit depth {bit_depth} and color type {actual_color_type}"
        )


validate_png(
    "store_assets/play-icon-512.png",
    width=512,
    height=512,
    color_type=6,
    maximum_bytes=1_048_576,
)
validate_png(
    "store_assets/feature-graphic-1024x500.png",
    width=1024,
    height=500,
    color_type=2,
    maximum_bytes=15_728_640,
)


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
    if not re.search(r'applicationId\s*=\s*"com\.myidealbody\.ai"', build_text):
        ERRORS.append("permanent Android applicationId must remain com.myidealbody.ai")

app_config = ROOT / "mobile/lib/core/app_config.dart"
if app_config.is_file():
    app_config_text = app_config.read_text(encoding="utf-8")
    if not re.search(
        r"androidPackageName\s*=\s*'com\.myidealbody\.ai'",
        app_config_text,
    ):
        ERRORS.append("Dart Android package name must remain com.myidealbody.ai")
    for required_url in (
        "https://meetmetisa-dev.github.io/myidealbody-ai/privacy.html",
        "https://meetmetisa-dev.github.io/myidealbody-ai/terms.html",
        "https://meetmetisa-dev.github.io/myidealbody-ai/support.html",
    ):
        if required_url not in app_config_text:
            ERRORS.append(f"missing public mobile disclosure URL: {required_url}")

release_workflow = ROOT / ".github/workflows/build-play-aab.yml"
if release_workflow.is_file():
    workflow_text = release_workflow.read_text(encoding="utf-8")
    if '--dart-define=APP_VERSION="$VERSION_NAME"' not in workflow_text:
        ERRORS.append("signed AAB workflow must align the displayed app version")

main_activity = ROOT / "mobile/android/app/src/main/kotlin/com/myidealbody/ai/MainActivity.kt"
if main_activity.is_file() and not re.search(
    r"package\s+com\.myidealbody\.ai\b",
    main_activity.read_text(encoding="utf-8"),
):
    ERRORS.append("MainActivity package must remain com.myidealbody.ai")

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
