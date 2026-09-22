# MyIdealBody AI — Android Flutter client

An Android-first MVP for estimating calories and protein from a meal photo. The app ships with English and Bahasa Indonesia, heuristic ranges, reviewable foods, editable portions, a local diary, camera/gallery input, and Google Play subscription plumbing.

This client separates a fully local fixed-result demo from the optional real-photo path. Camera guidance checks only light and framing. In production mode, nutrition is estimated after a still image is uploaded; results default to ranges and must be reviewed before saving.

## What works

- English and Bahasa Indonesia via Flutter `gen-l10n` and ARB files
- privacy-first onboarding and a persistent language choice
- Material 3 home dashboard with calorie/protein goals
- camera capture, gallery picker, plate guide, and sampled brightness guidance
- safe default demo mode that returns a clearly labeled fixed sample entirely on-device, with no API or file read
- production-mode multipart upload with explicit JPEG/PNG/WebP MIME detection
- calorie, protein, carbohydrate, and fat ranges plus confidence
- editable portions with recalculated totals; food renaming stays locked until catalog remapping exists
- visible hidden-ingredient caveats and review-only follow-up prompts
- on-device diary/history and destructive-data confirmation
- free limit of three successful analyses per day
- subscription product discovery using prices returned by Google Play
- settings for language, goals, cloud consent, local deletion, and disclosures
- cached camera photos deleted after the result flow; gallery originals are never changed

## Requirements

- Flutter 3.47.5 stable (Dart 3.13.4) or a compatible newer stable version
- Android SDK 36
- JDK 17
- a running MyIdealBody API (the sibling `backend` project) only for `DEMO_MODE=false`

The Android host uses AGP 8.13.2, Gradle 8.14.4, Kotlin 2.3.21, `minSdk 24`, and `targetSdk 36`.

## Run locally

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=DEMO_MODE=true
```

The local demo needs no backend or API URL. It does not read the selected image during analysis, make an analysis request, initialize Play Billing, consume the scan allowance, or allow its fixed sample to be saved.

For a reviewed development build of the real-photo path, `10.0.2.2` reaches the host machine from the Android emulator:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=DEMO_MODE=false
```

Debug builds allow cleartext HTTP only for `10.0.2.2` and `localhost`; the release manifest refuses cleartext traffic. Use an HTTPS API origin without `/v1` for physical-device and production builds.

For a USB-connected Android phone running the debug build, keep the development
API on the computer and forward it through Android Debug Bridge:

```bash
adb reverse tcp:8000 tcp:8000
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=DEMO_MODE=false
```

This avoids exposing the development server to the local network. Remove the
forward later with `adb reverse --remove tcp:8000`.

`DEMO_MODE` defaults to `true`: the app keeps the selected image on-device and returns its bundled sample without HTTP. Set `--dart-define=DEMO_MODE=false` only for a reviewed build connected to a real recognition provider with final privacy disclosures.

The included standard Gradle wrapper bootstraps Gradle 8.14.4. Do not regenerate
the Android host with `flutter create` unless you intentionally preserve and
reapply the package name, signing configuration, manifest policy, and native
method channel from this repository.

## API contract

With `DEMO_MODE=false`, the client sends a multipart request:

- `image`: JPEG, PNG, or WebP
- `locale`: `en` or `id`
- `source`: `camera` or `gallery`

Expected response shape:

```json
{
  "analysis_id": "…",
  "total": {
    "calories": {"min": 400, "max": 560, "estimated": 480},
    "protein_g": {"min": 22, "max": 34, "estimated": 28},
    "carbs_g": {"min": 45, "max": 70, "estimated": 58},
    "fat_g": {"min": 12, "max": 24, "estimated": 18}
  },
  "confidence": 0.72,
  "foods": [],
  "caveats": [],
  "follow_up_questions": [],
  "provider": "mock"
}
```

The backend currently provides a deterministic mock recognizer by default. A production vision provider and a validated/licensed Indonesian nutrition catalog are still required before health claims or a public launch.

## Pricing and Google Play Billing

Product IDs are fixed in `lib/core/app_config.dart`:

- `myidealbody_pro_monthly`
- `myidealbody_pro_annual`

Recommended launch configuration in Play Console:

| Plan | Indonesia | Other markets starting point |
|---|---:|---:|
| Monthly | Rp49.000/month | about US$4.99/month |
| Annual launch | Rp299.000/year | about US$19.99/year |

These are product-strategy inputs, not hardcoded checkout prices. The real paywall uses `ProductDetails.price`, allowing Play to show the buyer’s currency, taxes, and regional pricing. Preview copy is clearly labeled and the subscribe button stays disabled when Play products or secure verification are unavailable.

### Required billing integration before enabling purchase

Purchases fail closed by design. The default `ApiService` has no auth provider, so `SubscriptionService.verificationReady` remains false and no real Play purchase can start.

Pro access is not trusted from local preferences. On a configured build, the app restores Play purchases at startup and grants access only after the backend returns an active entitlement.

After implementing user accounts, inject a short-lived user access token:

```dart
final api = ApiService(
  authTokenProvider: () async => authSession.currentAccessToken,
);
final controller = await AppController.load(api: api);
```

The backend billing endpoint must accept and authorize that user session, bind the purchase to the user, and return `entitlement_active`. Never embed the backend’s internal billing bearer token, a service-account key, or any production secret in the APK. Also add Play real-time developer notifications, idempotent entitlement updates, acknowledgement handling, and restore testing before release.

## Localization

Source translations live in:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_id.arb`

To add a language, copy the English ARB to `app_<locale>.arb`, translate every message while preserving ICU placeholders, run `flutter gen-l10n`, and add localized store listing text in Play Console. Dates and numbers already use the active locale.

## Verification

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=https://example.invalid
```

CI runs those checks on Flutter 3.47.5. This workspace did not have Flutter or Dart installed, so the generated localization files, package lockfile, analyzer results, tests, and APK must be produced by CI or a Flutter workstation.

## Build a Play Store bundle

Google Play accepts a signed Android App Bundle (`.aab`), not this repository's
source ZIP. The permanent package name is confirmed as `com.myidealbody.ai`.
Do not change it: a different application ID creates a different Play app and
cannot update the existing listing.

### Secure manual GitHub build

The manual **Build signed Play AAB** workflow uses the protected `play-release`
environment, is restricted to `main`, and never creates a signing key. Configure
these GitHub secrets in that environment (or as repository secrets if the
environment has no same-named override):

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_STORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `ANDROID_UPLOAD_CERT_SHA256` (optional but recommended wrong-key guard)
- `PRODUCTION_API_BASE_URL` (required only for `production_photo`; an HTTPS
  origin such as `https://api.example.org`, without `/v1`, credentials, query,
  or fragment)

Protect `play-release` with required reviewers and a `main` deployment-branch
rule. Run the workflow with a new semantic `version_name` and strictly
increasing integer `version_code`:

- `local_demo` is the safe default. Confirm
  `LOCAL_DEMO_INTERNAL_OR_CLOSED_TEST`; it builds with `DEMO_MODE=true` and no
  API dependency. Use it only for Internal or Closed Testing with demo-accurate
  listing and declarations.
- `production_photo` requires the exact
  `BUILD_SIGNED_REAL_PHOTO_AAB` confirmation, the fixed API secret, and a health
  endpoint reporting the real provider. A successful build is not proof that
  the provider, catalog, privacy disclosures, billing, or Data Safety answers
  are production-ready.

The workflow uploads the signed `.aab` and its SHA-256 checksum as a GitHub
Actions artifact for seven days. Anyone authorized to read workflow artifacts
for this repository may download it. The workflow does not publish to Google
Play.

The **Lock Flutter dependencies** workflow uses the pinned Flutter version and
commits only `mobile/pubspec.lock` when `pubspec.yaml` changes. The signed-AAB
workflow refuses to run without that committed lockfile. Review dependency
changes before any production build.

### Local signing

Create and securely back up an upload keystore outside the repository:

```bash
keytool -genkeypair -v \
  -keystore /secure/path/myidealbody-upload.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
cp android/key.properties.example android/key.properties
```

Edit the untracked `android/key.properties` to reference that keystore. Do not
commit the keystore, `key.properties`, or passwords. Then build the production
bundle with the real HTTPS API endpoint and real-photo mode explicitly enabled:

```bash
flutter pub get
flutter gen-l10n
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=DEMO_MODE=false
```

The signed artifact is written to
`build/app/outputs/bundle/release/app-release.aab`. Verify its signature before
uploading:

```bash
jarsigner -verify -verbose -certs \
  build/app/outputs/bundle/release/app-release.aab
```

The release build fails deliberately when neither secure CI signing variables
nor `android/key.properties` are configured, preventing an unsigned bundle from
being mistaken for a Play-ready artifact. The manual workflow supplies version
name/code inputs; for local builds, increment the `+1` build number in
`pubspec.yaml` for every subsequent Play upload.

## Before Play Store release

- replace the mock recognizer and benchmark it on labeled Indonesian meals
- obtain lawful nutrition data and document provenance (especially TKPI use)
- verify the published privacy-policy, terms, and support URLs from the exact release build
- complete user authentication, account export/deletion, and secure billing verification
- enforce free-scan quotas server-side; the MVP uses short-lived device timestamps only
- configure Play products, base plans, regional prices, and license testers
- configure an upload keystore; do not use debug signing for production
- re-encode photos client-side before upload to remove EXIF; the client already replaces the original filename, but picker metadata options do not document a byte-level sanitization guarantee
- run camera, denial, low-light, gallery, offline, large-text, and TalkBack tests on real devices
- validate photo-provider retention and deletion terms
- complete Play Data safety and Health apps declarations

Known MVP limitations: follow-up prompts are review notes and do not alter nutrition totals; detected food names cannot yet be remapped; diary data stays on the device; manual food search is not implemented; no account is created; and the production-photo policy/provider details are not finalized.
