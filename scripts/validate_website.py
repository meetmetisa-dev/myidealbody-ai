#!/usr/bin/env python3
"""Dependency-free structural checks for the static bilingual website."""

from __future__ import annotations

import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[1]
WEBSITE = ROOT / "website"
ERRORS: list[str] = []


class WebsiteParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: list[str] = []
        self.copy_keys: set[str] = set()
        self.aria_keys: set[str] = set()
        self.assets: set[str] = set()
        self.api_attribute_seen = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if element_id := values.get("id"):
            self.ids.append(element_id)
        if key := values.get("data-i18n"):
            self.copy_keys.add(key)
        if key := values.get("data-i18n-aria"):
            self.aria_keys.add(key)
        if tag == "body" and "data-api-base-url" in values:
            self.api_attribute_seen = True
        for attribute in ("src", "href"):
            value = values.get(attribute)
            if not value or value.startswith(("#", "data:", "mailto:", "tel:")):
                continue
            parsed = urlparse(value)
            if not parsed.scheme and not parsed.netloc:
                self.assets.add(parsed.path)


def object_keys(source: str, start: str, end: str) -> set[str]:
    match = re.search(re.escape(start) + r"(.*?)" + re.escape(end), source, re.DOTALL)
    if not match:
        ERRORS.append(f"could not locate JavaScript block beginning with {start!r}")
        return set()
    return set(re.findall(r"^\s{4}([A-Za-z][A-Za-z0-9_]*):", match.group(1), re.MULTILINE))


html_path = WEBSITE / "index.html"
js_path = WEBSITE / "app.js"
css_path = WEBSITE / "styles.css"
for path in (html_path, js_path, css_path):
    if not path.is_file() or path.stat().st_size == 0:
        ERRORS.append(f"missing or empty website file: {path.relative_to(ROOT)}")

parser = WebsiteParser()
if html_path.is_file():
    parser.feed(html_path.read_text(encoding="utf-8"))
    duplicates = sorted({item for item in parser.ids if parser.ids.count(item) > 1})
    if duplicates:
        ERRORS.append(f"duplicate HTML IDs: {duplicates}")
    if not parser.api_attribute_seen:
        ERRORS.append("website body must declare data-api-base-url")
    for asset in sorted(parser.assets):
        if asset and not (WEBSITE / asset).is_file():
            ERRORS.append(f"missing local website asset: {asset}")

if js_path.is_file():
    javascript = js_path.read_text(encoding="utf-8")
    indonesian = object_keys(javascript, "  const indonesian = {", "\n  };\n\n  const indonesianAria")
    indonesian_aria = object_keys(javascript, "  const indonesianAria = {", "\n  };\n\n  const metaDescription")
    missing_copy = sorted(parser.copy_keys - indonesian)
    missing_aria = sorted(parser.aria_keys - indonesian_aria)
    if missing_copy:
        ERRORS.append(f"HTML translation keys missing from Indonesian copy: {missing_copy}")
    if missing_aria:
        ERRORS.append(f"HTML ARIA translation keys missing from Indonesian copy: {missing_aria}")

if css_path.is_file():
    css = css_path.read_text(encoding="utf-8")
    if css.count("{") != css.count("}"):
        ERRORS.append("website CSS braces are unbalanced")

if ERRORS:
    print("Website validation failed:", file=sys.stderr)
    for error in ERRORS:
        print(f"- {error}", file=sys.stderr)
    raise SystemExit(1)

print(
    "Website validation passed: "
    f"{len(parser.copy_keys)} bilingual text keys, "
    f"{len(parser.aria_keys)} bilingual ARIA keys, "
    f"{len(parser.ids)} unique IDs."
)
