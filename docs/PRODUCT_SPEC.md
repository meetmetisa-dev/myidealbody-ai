# Product specification: MyIdealBody AI MVP

## Product thesis

MyIdealBody AI helps English- and Indonesian-speaking adults log calories and protein from a meal photo in under a minute. The defensible starting niche is everyday Indonesian food. The product favors editable ranges and visible uncertainty over false precision.

The first release uses **real-time camera guidance** (framing, lighting, distance) and performs nutrition analysis after a still photo is captured. Continuous live calorie estimation is not an MVP promise: it consumes more battery/data and does not solve hidden ingredients or portion ambiguity.

## Target users and job

Primary: Indonesian gym beginners and busy adults who want to hit a protein or calorie goal but stop using manual food search. Secondary: international users who want faster photo logging.

Core job: “When I am about to eat, let me capture the plate, correct any wrong assumptions quickly, and save a useful calorie/protein estimate.”

## MVP scope

The table below is the **closed-beta release target**, not a claim that every item is complete in this source milestone. The current repository implements the main bilingual photo flow, editable detected portions, local diary, range-first results, and a fail-closed Play Billing interface. Before a paid/public release it still needs authenticated server quotas, idempotent analysis retries, nutrient recalculation for clarification answers, manual food add/search, edit of saved diary entries, account export/deletion if accounts are introduced, and production policy/support URLs. See each component README for the exact runnable status.

| Area | Requirement | Acceptance signal |
|---|---|---|
| Onboarding | Choose English or Indonesian; explain estimation limits; optionally set calorie/protein goals | Can finish without creating an account or enabling marketing consent |
| Home | Show today's calories/protein, remaining goal, meals, and scan button | Empty, loading, error, free-limit, and Pro states are localized |
| Capture | Camera preview, framing/lighting guidance, shutter, retake, and gallery picker | Permission denial and unsupported camera fail gracefully |
| Analysis | Upload one still image; return detected components, portions, nutrient ranges, confidence, and assumptions | Retry is idempotent and no result claims clinical accuracy |
| Clarification | Ask only high-impact questions such as oil, sauce, sugar, santan, or portion size | Answers recalculate nutrients without another paid model call where possible |
| Correction | Add/remove food, change item, portion, unit, or cooking method | Updated totals and ranges appear immediately |
| Diary | Save, view, edit, and delete meals; daily summary and 7-day free history | Data persists across restart; deletion is confirmed and synchronized |
| Subscription | Free allowance, monthly/annual paywall, purchase, restore, manage/cancel, entitlement sync | UI uses Play-returned prices; offline state never invents entitlement |
| Settings | Language, privacy, export/delete, account deletion, subscription, disclaimer, support | English and Indonesian paths have feature parity |

Suggested free allowance: three **completed** analyses per local calendar day. Failed uploads, server errors, and user cancellations do not consume an allowance.

## Analysis contract

The vision layer identifies likely components and portions; it does not invent nutrient values. The nutrition layer maps confirmed foods and quantities to a versioned nutrient database and calculates totals.

Each result should contain:

- component name/key, preparation method, estimated grams, and portion range;
- calories and protein as a range plus a display midpoint;
- component and meal confidence (`low`, `medium`, `high`);
- assumptions and one or two high-impact clarification questions;
- nutrition source/version and analysis ID;
- a clear “edit result” action.

If confidence is low, say so and prioritize correction. Never show decimal-level precision for an image-derived portion. If no food is recognized, do not consume quota and offer retake/manual entry.

## Bilingual requirements

Version 1 locales are `en` and `id`; English is the fallback. Locale architecture must allow new ARB/resource files without rewriting screens.

- No user-facing string is hard-coded in widgets, API errors, notifications, permission rationale, paywalls, or accessibility labels.
- Server responses use stable error/food keys plus parameters; the client localizes them. Do not ship model prose directly as UI copy.
- Format numbers, dates, plural forms, currencies, and units by locale. Respect Play's returned price string.
- Support grams plus familiar Indonesian portions such as `porsi`, `sendok makan`, `centong`, `potong`, and `butir`, with tested nutrition conversions.
- Use “Bahasa Indonesia” in the language picker; commission native review for both store listing and high-risk health/payment copy.
- Expansion order after evidence of demand: Malay, Spanish, Portuguese, then additional markets based on retained usage—not installs alone.

## Non-goals for v1

- Continuous video-based calorie/protein estimation.
- Medical diagnosis, eating-disorder treatment, clinical diet plans, guaranteed weight change, or children's nutrition advice.
- Exact hidden-ingredient detection from pixels.
- Barcode scanning, restaurant integrations, social feed, coach marketplace, wearables, Health Connect, or iOS.
- Using user photos for model training without separate opt-in.

## Quality requirements

- Establish a consented, labeled evaluation set that includes nasi Padang, warteg plates, soups, mixed dishes, drinks, packaged foods, and adverse conditions. Keep it separate from training.
- Report component recognition, portion error, calorie/protein absolute percentage error, clarification frequency, and failure rate by food class. Averages alone are insufficient.
- Launch only after safety review finds no “exact” or medical claims and users can correct every result.
- Target an initial result within 8 seconds at p95 on a normal Indonesian 4G connection; show progress, allow cancellation, and handle delayed jobs safely.
- Meet basic screen-reader labels, scalable text, contrast, 48dp touch targets, and non-color-only confidence cues.
- Crash-free sessions, API availability, and inference spend have alerts and release rollback thresholds defined before rollout.

## Success measures

The north-star behavior is **corrected meals saved per retained weekly user**. Supporting measures are first-scan completion, result-to-save rate, median correction time, repeated correction rate by dish, D7/D30 retention, paid conversion, churn/refunds, analysis latency/failure, support rate, and inference cost per active/paid user.

## Roadmap

### MVP / closed beta

Photo capture, bilingual UI, deterministic nutrient calculation, ranges/confidence, corrections, local diary, free quota, Play subscriptions, privacy/deletion surfaces, and Indonesian-food evaluation.

### Post-MVP 1: improve trust

Account sync, export, stronger Indonesian database, learned portion priors, correction-based evaluation, meal photo opt-in storage, and transparent accuracy reports.

### Post-MVP 2: increase utility

Barcode/manual search, recipe decomposition, weekly insights, protein suggestions, saved meals, restaurant/brand catalog, and carefully scoped Health Connect integration.

### Post-MVP 3: expand

Additional languages, iOS, dietitian collaboration features, and on-device models where they materially improve cost, latency, or privacy.

## Launch decisions still required

- Final brand/package/domain and legal publishing entity.
- Production vision/model provider, data-processing terms, region, and cost caps.
- Licensed nutrition sources. Confirm commercial reuse rights for Indonesian data; do not assume that public access equals commercial permission.
- Public privacy-policy and account-deletion URLs.
- Play Console products, payment profile, support workflow, and production credentials.
- Whether account sync ships at launch; if it does, deletion and export must ship with it.

This product provides estimates for general wellness. Accuracy claims must be backed by the shipped model and a representative, versioned evaluation—not a prototype demo.
