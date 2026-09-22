# MyIdealBody AI

Android-first nutrition-tracking MVP designed for reviewable calorie and protein
ranges from a meal photo. The current safe beta is an explicitly labeled local
sample; real photo recognition remains behind a production-readiness gate.

**Live bilingual product preview:** https://meetmetisa-dev.github.io/myidealbody-ai/

This repository contains a bilingual English/Bahasa Indonesia MVP:

- `mobile/` — Flutter Android client with onboarding, camera/gallery capture, camera guidance, editable analysis results, diary, settings, and Google Play subscription UI.
- `backend/` — FastAPI service with an offline demo recognizer, deterministic nutrition calculation, confidence ranges, upload safeguards, and an optional vision-model adapter.
- `website/` — dependency-free bilingual product preview designed for GitHub Pages.
- `docs/` — product, pricing, privacy/security, and Play Store launch guides.
- `content/` — paired English/Indonesian UX copy and translation QA guidance for future screens and languages.

## Current milestone

This is a complete **source MVP for development and closed-beta work**, not a ready-to-publish paid health app. The safe default Android demo creates one fixed sample plate entirely on-device: it does not inspect or upload the selected photo, contact an analysis API, initialize Play Billing, consume the scan allowance, or save the sample to the diary. Production model/data validation is still required. Detected portions can be resized or removed, but food renaming and hidden-ingredient recalculation remain locked until catalog search and deterministic recalculation are added. Real billing stays disabled until per-user authentication and server verification are connected. The three-scan free limit for future non-demo analysis is currently enforced on-device only; production must enforce quota, idempotency, and abuse controls on the server.

> **Important:** The included recognition mode is a deterministic demo, not a clinically reliable food-measurement system. A single photo cannot reveal exact weight or hidden oil, sugar, sauces, or coconut milk. The product therefore uses ranges, confidence labels, follow-up questions, and user correction. It is not medical advice.

## Recommended pricing

| Market | Monthly | Annual launch price | Notes |
|---|---:|---:|---|
| Indonesia | Rp49.000 | Rp299.000 | Good entry price for a focused consumer app |
| International | US$4.99 | US$19.99 | Better fit than US$20/month for a new self-service tracker |

Suggested free allowance: three analyses per day with manual editing and diary access. Configure the real price and regional availability in Google Play Console; the app displays the localized price returned by Google Play rather than hardcoding currency text.

Subscription product IDs:

- `myidealbody_pro_monthly`
- `myidealbody_pro_annual`

## Run the backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --env-file .env
```

Open `http://localhost:8000/docs` for the interactive API documentation. The default mock provider runs without an external AI key.

## Run the Android app

Install the current stable Flutter SDK and Android Studio, then:

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter run --dart-define=DEMO_MODE=true
```

`10.0.2.2` routes the Android emulator to the backend running on the development computer. For a USB-connected physical phone, keep the API bound to the computer and run `adb reverse tcp:8000 tcp:8000`, then launch Flutter with `--dart-define=API_BASE_URL=http://localhost:8000`. This matches the debug-only network policy and avoids exposing the development server to the LAN. Remove the forwarding rule afterward with `adb reverse --remove tcp:8000`. Production builds require a public HTTPS API.

A future paid Play build also needs products created in Play Console, per-user
backend authentication, and server-side entitlement storage. Until secure
verification and Play products are configured, the app remains usable in
clearly labeled demo/free mode and cannot start a real purchase.

For the current safe beta, use the manual **Build signed Play AAB** GitHub
workflow in `local_demo` mode. It builds the fixed on-device demonstration and
does not need an API. Signing-secret setup and local signing commands are in
[`mobile/README.md`](mobile/README.md#build-a-play-store-bundle); the new-personal-account
submission sequence is in
[`docs/play-store/NEW_PERSONAL_ACCOUNT_CHECKLIST.md`](docs/play-store/NEW_PERSONAL_ACCOUNT_CHECKLIST.md).
The 512 px Play icon and 1024 × 500 feature graphic are ready in
[`store_assets/`](store_assets/); capture authentic phone screenshots from the
signed release build rather than inventing mock screenshots.

## Preview the website

```bash
python3 -m http.server 8080 --directory website
```

Open `http://localhost:8080`. The Pages workflow deploys only `website/`. With the default blank `data-api-base-url`, users can choose or capture a photo, preview it locally, and create a clearly labeled guided estimate from their meal and portion selections; the photo is not uploaded or treated as visually recognized.

To enable real photo analysis, deploy `backend/` separately behind HTTPS with a production vision provider, then set `data-api-base-url` on `website/index.html` to that origin without `/v1`. The browser downsizes and re-encodes the image before posting it to `/v1/analyze`, and the backend must allow `https://meetmetisa-dev.github.io` in `CORS_ORIGINS`. Never put the provider API key in the website JavaScript.

## Quality checks

```bash
# Backend
cd backend
pip install -r requirements-dev.txt
python -m pytest

# Mobile (requires Flutter)
cd ../mobile
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

GitHub Actions runs both checks on every push. This workspace did not include the Flutter SDK, so backend tests can run locally here while the mobile project is structurally validated and is compiled in CI or on a Flutter-equipped machine.

## Before a public launch

1. Replace the demo recognizer with a measured production pipeline and validate it on representative Indonesian meals.
2. Connect an authorized nutrition database. USDA FoodData Central is suitable for many global ingredients; confirm commercial permission before importing TKPI data.
3. Add per-user authentication and server-side quotas/idempotency; configure Play Billing, entitlement storage/notifications, signing, privacy-policy and account-deletion URLs.
4. Complete Google Play Data Safety and Health Apps declarations and the required closed test for eligible new personal developer accounts.
5. Run privacy, security, accessibility, device, and low-connectivity testing.

Detailed operational steps are in `docs/`.

## License status

No open-source license has been selected. Public visibility does not grant permission to reuse, redistribute, or commercialize this source. Add the owner's chosen license before accepting outside contributions or reuse.
