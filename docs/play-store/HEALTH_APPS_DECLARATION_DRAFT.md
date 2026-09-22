# Google Play Health Apps declaration draft

Status: **draft for Play Console — not submitted**  
Prepared: 22 September 2026

All apps published on closed, open, or production tracks must complete the Health Apps declaration. Google defines dietary-intake tracking, meal planning, diets, and weight-management tools under **Health and fitness > Nutrition and Weight Management**. See the official [Health Apps declaration guidance](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en) and [Health Content and Services policy](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en-GB_nz&rd=2).

## Proposed Play Console selection

Select:

- **Health and fitness**
  - **Nutrition and Weight Management**

Do not select based on the current source:

- Activity and Fitness
- Period Tracking
- Sleep Management
- Stress Management, Relaxation, Mental Acuity
- Any Medical category
- Medical Device Apps
- Health subjects research

Why: this closed-test build previews a planned calorie and macronutrient review
flow, displays a clearly labeled fixed nutrition sample, and lets users set
local calorie/protein goals. The wider source includes a local diary for future
non-demo results. It does not diagnose, treat, manage a disease, make clinical
decisions, conduct research, read/write Health Connect, or interface with
medical hardware.

Revisit the selections if the product later adds workout tracking, body weight, health-condition plans, dietitian/clinical workflows, research recruitment, or Health Connect.

## Reviewer description draft — local-demo AAB

> MyIdealBody AI is a general-wellness nutrition product demonstration for adults. A tester can capture or select one still meal photo to review the planned interface, but this closed-test build does not inspect or upload that image or contact an analysis service. It creates one clearly labeled fixed calorie and macronutrient sample on-device. The tester may adjust sample portions, but the sample cannot be saved to the diary or treated as a real scan. The app does not diagnose, treat, cure, prevent, or manage a medical condition and is not intended to replace advice from a qualified healthcare professional.

For a future `DEMO_MODE=false` build, replace this entire paragraph with a
release-specific description naming the verified provider and stating the
actual upload, retention, correction, and save behavior. Do not claim accuracy
until a representative evaluation of the shipped model and nutrition data
supports the claim.

## Consumer disclaimer

English:

> MyIdealBody AI provides approximate calorie and macronutrient estimates for general wellness. It is not a medical device and does not provide diagnosis, treatment, or medical advice. Results can vary with portion size, recipes, cooking methods, and hidden ingredients. Consult a qualified healthcare professional for medical advice.

Bahasa Indonesia:

> MyIdealBody AI memberikan perkiraan kalori dan makronutrien untuk kebugaran umum. Aplikasi ini bukan alat medis dan tidak memberikan diagnosis, pengobatan, atau saran medis. Hasil dapat berbeda karena ukuran porsi, resep, cara memasak, dan bahan yang tidak terlihat. Konsultasikan kebutuhan medis kepada tenaga kesehatan yang berkualifikasi.

Place materially consistent text in onboarding, the result screen, Settings, store listing, and public privacy policy. The current app already presents estimate/medical disclaimers, but the final localized screenshots and release build must be checked.

## Health-policy evidence checklist

- [x] Health feature is limited to nutrition and weight-management support in the current product scope.
- [x] Current manifest requests only camera and internet; no Health Connect, body-sensor, location, microphone, contacts, or broad media permission is declared.
- [x] Camera hardware is optional; users can choose a gallery image.
- [x] Results contain ranges, confidence, caveats, and a statement that they are estimates rather than medical measurements.
- [ ] **BLOCKER:** Confirm that `https://meetmetisa-dev.github.io/myidealbody-ai/privacy.html` is deployed, active, non-geofenced, and matches the exact AAB.
- [x] Settings contains working external links for the privacy policy, terms, and support pages, with graceful failure handling.
- [ ] **BLOCKER:** Name the publishing legal entity consistently in Play Console and the privacy policy.
- [x] This closed-test draft is frozen to the fully local `DEMO_MODE=true`
  behavior. Never reuse it for a production-photo build.
- [ ] For production photo upload, state the actual API/model processor, purpose, transfer, retention/deletion, and user controls in the privacy policy and consent screen.
- [ ] Confirm the final listing does not promise exact calorie measurement, diagnosis, guaranteed weight loss, medical treatment, or invisible-ingredient detection.
- [x] The current beta listing and public terms specify an adults-only (18+)
  audience and do not target children. Re-review if that audience changes.
- [ ] Provide reviewers a functioning no-login path or complete App access instructions.

## Camera/device wording for the store listing

Suggested wording:

> Photo capture requires a compatible Android camera. Users may instead select a supported JPEG, PNG, or WebP image from the system picker. The closed-test demo does not inspect the image. A future reviewed production mode would analyze one still image; neither mode continuously measures calories from video or uses the camera as a medical sensor.

This matches the manifest's optional camera feature and avoids implying that a camera produces a medical measurement.

## Final declaration record

Before submitting, record:

| Field | Final value |
|---|---|
| Git commit | `BLOCKED — insert release commit` |
| AAB SHA-256 | `BLOCKED — insert signed artifact checksum` |
| Version code/name | `BLOCKED — confirm release values` |
| Demo or production upload | `DEMO_MODE=true` / `local_demo` for this closed-test draft |
| Selected Health Apps categories | `Nutrition and Weight Management` unless features change |
| Privacy policy URL | `https://meetmetisa-dev.github.io/myidealbody-ai/privacy.html` — verify live deployment before submission |
| Reviewer contact | `BLOCKED` |
| Date rechecked against Play policy | `BLOCKED — recheck immediately before submission` |
