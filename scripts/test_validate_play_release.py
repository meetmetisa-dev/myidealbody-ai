from __future__ import annotations

import unittest
from pathlib import Path

from scripts.check_production_health import validate_health_payload
from scripts.validate_play_release import (
    validate_api_base_url,
    validate_application_id,
    validate_versions,
)


class ReleaseUrlValidationTest(unittest.TestCase):
    def test_accepts_public_https_api(self) -> None:
        self.assertEqual(validate_api_base_url("https://api.myidealbody.ai"), [])

    def test_rejects_unsafe_or_placeholder_urls(self) -> None:
        rejected = (
            "http://api.myidealbody.ai",
            "https://localhost",
            "https://127.0.0.1",
            "https://10.0.2.2",
            "https://api.example.com",
            "https://user:password@api.myidealbody.ai",
            "https://api.myidealbody.ai?token=value",
            "https://api.myidealbody.ai?",
            "https://api.myidealbody.ai#",
            "https://api.myidealbody.ai/v1",
            "https://api.myidealbody.ai:8443",
        )
        for url in rejected:
            with self.subTest(url=url):
                self.assertTrue(validate_api_base_url(url))

    def test_repository_uses_confirmed_application_id(self) -> None:
        root = Path(__file__).resolve().parents[1]
        self.assertEqual(validate_application_id(root), [])

    def test_accepts_android_versions(self) -> None:
        self.assertEqual(validate_versions("0.1.0-beta.1", "42"), [])

    def test_rejects_invalid_android_versions(self) -> None:
        self.assertTrue(validate_versions("release", "0"))
        self.assertTrue(validate_versions("1.0.0", "01"))
        self.assertTrue(validate_versions("1.0.0", "2100000001"))

    def test_accepts_real_provider_health_response(self) -> None:
        self.assertEqual(
            validate_health_payload(
                {"status": "ok", "provider": "openai_compatible"}
            ),
            [],
        )

    def test_rejects_demo_or_malformed_health_response(self) -> None:
        self.assertTrue(validate_health_payload({"status": "ok", "provider": "mock"}))
        self.assertTrue(validate_health_payload(["not", "an", "object"]))


if __name__ == "__main__":
    unittest.main()
