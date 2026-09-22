#!/usr/bin/env python3
"""Fail closed before a signed Play build can access repository secrets."""

from __future__ import annotations

import ipaddress
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlsplit


EXPECTED_APPLICATION_ID = "com.myidealbody.ai"
LOCAL_DEMO_MODE = "local_demo"
PRODUCTION_PHOTO_MODE = "production_photo"
LOCAL_DEMO_CONFIRMATION = "LOCAL_DEMO_INTERNAL_OR_CLOSED_TEST"
PRODUCTION_CONFIRMATION = "BUILD_SIGNED_REAL_PHOTO_AAB"
ALLOWED_REF = "refs/heads/main"


def validate_api_base_url(raw: str) -> list[str]:
    errors: list[str] = []
    if not raw or raw != raw.strip():
        return ["API base URL is required and cannot contain surrounding whitespace"]
    if len(raw) > 2048 or any(ord(character) < 32 for character in raw):
        return ["API base URL contains invalid characters"]

    try:
        parsed = urlsplit(raw)
        port = parsed.port
    except ValueError:
        return ["API base URL is malformed"]

    if parsed.scheme != "https":
        errors.append("API base URL must use https")
    if not parsed.hostname:
        errors.append("API base URL must include a hostname")
        return errors
    if parsed.username is not None or parsed.password is not None:
        errors.append("API base URL cannot contain credentials")
    if "?" in raw or "#" in raw:
        errors.append("API base URL cannot contain a query string or fragment")
    if parsed.path not in ("", "/"):
        errors.append("API base URL must be an origin without a path")
    if port not in (None, 443):
        errors.append("API base URL must use the standard HTTPS port 443")

    hostname = parsed.hostname.rstrip(".").lower()
    blocked_names = {"localhost", "localhost.localdomain"}
    blocked_suffixes = (".localhost", ".local", ".internal", ".invalid", ".test")
    example_names = {"example.com", "example.net", "example.org"}
    if hostname in blocked_names or hostname.endswith(blocked_suffixes):
        errors.append("API base URL cannot use a local or reserved hostname")
    if hostname in example_names or hostname.endswith(tuple(f".{item}" for item in example_names)):
        errors.append("API base URL cannot use an example hostname")

    try:
        address = ipaddress.ip_address(hostname)
    except ValueError:
        if "." not in hostname or not re.fullmatch(r"[a-z0-9.-]+", hostname):
            errors.append("API hostname must be a valid public DNS name")
    else:
        if not address.is_global:
            errors.append("API base URL cannot use a private or non-global IP address")

    return errors


def validate_versions(version_name: str, version_code: str) -> list[str]:
    errors: list[str] = []
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?", version_name):
        errors.append(
            "version name must use a semantic form such as 0.1.0 or 0.1.0-beta.1"
        )
    if len(version_name) > 100:
        errors.append("version name must be at most 100 characters")

    if not re.fullmatch(r"[1-9][0-9]*", version_code):
        errors.append("version code must be a positive integer without leading zeroes")
    else:
        parsed_code = int(version_code)
        if parsed_code > 2_100_000_000:
            errors.append("version code exceeds Android's supported range")
    return errors


def validate_application_id(root: Path) -> list[str]:
    checks = {
        "mobile/android/app/build.gradle.kts": (
            rf'applicationId\s*=\s*"{re.escape(EXPECTED_APPLICATION_ID)}"',
            "Gradle applicationId",
        ),
        "mobile/lib/core/app_config.dart": (
            rf"androidPackageName\s*=\s*'{re.escape(EXPECTED_APPLICATION_ID)}'",
            "Dart package name",
        ),
        "mobile/android/app/src/main/kotlin/com/myidealbody/ai/MainActivity.kt": (
            rf"package\s+{re.escape(EXPECTED_APPLICATION_ID)}\b",
            "Android Kotlin package",
        ),
    }
    errors: list[str] = []
    for relative, (pattern, label) in checks.items():
        path = root / relative
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            errors.append(f"{label} file is missing")
            continue
        if re.search(pattern, content) is None:
            errors.append(
                f"{label} must remain permanently set to {EXPECTED_APPLICATION_ID}"
            )
    return errors


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    release_mode = os.environ.get("RELEASE_MODE", "")
    confirmation = os.environ.get("RELEASE_CONFIRMATION", "")
    api_base_url = os.environ.get("API_BASE_URL", "")
    errors: list[str] = []

    if release_mode == LOCAL_DEMO_MODE:
        if confirmation != LOCAL_DEMO_CONFIRMATION:
            errors.append(
                f"local demo confirmation must be {LOCAL_DEMO_CONFIRMATION}"
            )
    elif release_mode == PRODUCTION_PHOTO_MODE:
        if confirmation != PRODUCTION_CONFIRMATION:
            errors.append(
                f"production photo confirmation must be {PRODUCTION_CONFIRMATION}"
            )
        errors.extend(validate_api_base_url(api_base_url))
    else:
        errors.append("release mode must be local_demo or production_photo")

    errors.extend(
        validate_versions(
            os.environ.get("VERSION_NAME", ""),
            os.environ.get("VERSION_CODE", ""),
        )
    )
    errors.extend(validate_application_id(root))

    if os.environ.get("GITHUB_REF") != ALLOWED_REF:
        errors.append("signed Play builds are restricted to the main branch")

    if errors:
        print("Play release validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        "Play release validation passed for the permanent application ID, "
        "release mode, and Android version."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
