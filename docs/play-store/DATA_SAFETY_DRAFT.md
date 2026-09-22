# Google Play Data Safety draft

Status: **working draft — do not submit unchanged**  
Prepared: 22 September 2026  
Scope template: package `com.myidealbody.ai`, source default `0.1.0+1`. Replace
the version and add the AAB checksum before submitting any answers.

This draft separates the repository's safe default build from the intended production build. Google defines collection as transmitting user data off the device, including transmission by an SDK. Data used only on-device is outside that definition. Data sent off-device and processed only in memory for no longer than the real-time request must still be entered in the form, although it may qualify as ephemeral processing. See Google's current [Data Safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en).

Do not submit the form until the exact signed AAB, backend deployment, infrastructure logging, model provider contract, and Play Billing configuration have been frozen and audited.

## Release configurations that must not be mixed

| Behavior | Safe source default | Future production upload |
|---|---|---|
| Build flag | `DEMO_MODE=true` by default | `DEMO_MODE=false` explicitly |
| Selected food photo | Remains on the device; no analysis request is made | Original JPEG/PNG/WebP bytes are sent to the configured API |
| Recognition | The app returns one bundled fixed sample without reading the image | Backend sends a resized, re-encoded JPEG plus a food-catalog prompt to an OpenAI-compatible vision provider |
| Saved diary | The fixed sample cannot be saved and does not consume scan allowance; goals, consent, and locale remain local | User-specific diary entries and scan timestamps remain local unless sync is added later |
| Billing | Billing initialization, product queries, checkout, and restore are disabled | Product ID and Play purchase token would be sent to the backend and then checked with Google Play |
| Accounts | No account or sign-in | Not implemented; required before the current verification design can be enabled safely |

Code evidence:

- [`AppConfig.demoMode`](../../mobile/lib/core/app_config.dart) defaults to `true`.
- [`ApiService.analyzeMeal`](../../mobile/lib/services/api_service.dart) immediately returns `_localDemoAnalysis` in demo mode and reads a selected file only when demo mode is disabled.
- [`MockRecognitionProvider`](../../backend/app/providers/mock.py) discards the supplied image.
- [`OpenAICompatibleRecognitionProvider`](../../backend/app/providers/openai_compatible.py) re-encodes and forwards an image to a configured provider.
- [`AppController`](../../mobile/lib/state/app_controller.dart) stores diary, goals, consent, locale, and scan history locally.
- [`SubscriptionService`](../../mobile/lib/services/subscription_service.dart) returns `BillingState.unavailable` before touching Play Billing in demo mode.
- The manifest requests only `CAMERA` and `INTERNET`, disables backup, and does not request location, microphone, contacts, or broad media/storage permissions: [`AndroidManifest.xml`](../../mobile/android/app/src/main/AndroidManifest.xml) and [`data_extraction_rules.xml`](../../mobile/android/app/src/main/res/xml/data_extraction_rules.xml).

## Form-level draft

| Play Console question | Demo-build draft | Production-upload draft | Status/evidence needed |
|---|---|---|---|
| Does the app collect or share required user-data types? | Candidate **No for the local demo only**: selected photos, sample results, goals, and preferences remain on-device; demo analysis and billing make no request. Confirm with the exact AAB and network capture before submission. | **Yes.** At minimum a user photo and derived dietary/nutrition information leave the device. Purchase information is also collected if subscriptions are enabled. | Audit every SDK, external-link behavior, final AAB, and network capture. |
| Is all collected data encrypted in transit? | If the final audit confirms no in-scope collection, answer the form consistently; do not claim an analysis transport. External policy/support pages use HTTPS. | Candidate **Yes only after verification** that mobile-to-API and API-to-provider paths use modern TLS and no fallback is possible. | Record production URLs and TLS test evidence. |
| Can users request deletion? | No in-app user account or server-side user profile exists. The app can clear its local diary; Android system settings can clear every local preference. | **Blocking** if any server retention or accounts are introduced. An in-app path plus public web deletion resource is required if users can create accounts. | Freeze retention/account design and test deletion through processors/backups. |
| Independent security review | **No** | **No**, unless a qualifying review is completed | Do not claim the optional badge without evidence. |

## Data-type worksheet

`BLOCKED` means a required fact is not present in this repository.

| Google Play data type | Demo mode | Production upload | Collection/purpose candidate | Sharing candidate | Required or optional |
|---|---|---|---|---|---|
| **Photos and videos > Photos** | User-selected photo: **not collected**. No image bytes or replacement asset are transmitted for analysis. | **Collected.** A meal photo is uploaded for recognition. | App functionality. Do **not** mark ephemeral until memory-only processing and vendor deletion are proven. | `BLOCKED`: depends on whether the selected vision vendor qualifies contractually as a service provider acting only on instructions. | Optional only if every user can decline cloud analysis and still use meaningful app functionality; otherwise required for the scan feature. |
| **Health and fitness > Health info** | Goals remain local; the fixed sample cannot be saved, and no user-specific health data is intentionally sent. | Conservative draft: **Collected.** Dietary intake is inferred and calories/macros are computed off-device from the uploaded meal. | App functionality; possibly personalization only if a future server actually uses goals/history to tailor results. | Same provider-role blocker as the photo. | Photo analysis is user initiated; confirm the form's optional/required answer against the final UX. |
| **App activity > App interactions / Other actions** | No demo-analysis interaction is transmitted; there is no analytics SDK in the source. Verify the exact AAB and external-link behavior. | Locale/source and any server-side quota/usage events may be collected. | App functionality. Add analytics only if an analytics purpose actually ships. | No sharing identified in current source; verify infrastructure and SDKs. | Re-evaluate against the final production UX. |
| **Financial info > Purchase history** | Demo mode does not initialize Play Billing or send purchase data. | **Collected** when the app sends product ID and a purchase token to the backend for entitlement verification. | App functionality and fraud prevention/security. | Google Play receives the token for verification; confirm whether each transfer is exempt service-provider processing and review the billing SDK's current disclosure guidance. | Optional: only subscribers provide it. |
| **Personal info > User IDs / Email** | Not collected; no account exists. | `BLOCKED`: authentication is not implemented. Declare any account ID/email if added. | Account management, app functionality, and fraud prevention only as implemented. | Depends on the selected identity provider and contract. | Depends on whether sign-in is optional. |
| **App info and performance** | No analytics/crash-reporting SDK is declared in `pubspec.yaml`. | None unless such an SDK is added. | If added: analytics and reliability, limited to the exact fields transmitted. | Audit the SDK before release. | Usually required once an always-on SDK is shipped. |
| **Device or other IDs** | No advertising/Firebase/device ID is intentionally collected in application code. | None planned, but `BLOCKED` pending final dependency and Play Billing SDK audit. | Do not select fraud/analytics uses without actual evidence. | Audit all transitive SDKs in the signed AAB. | Depends on final SDK behavior. |
| **Approximate location** | No location permission or location feature. | No intended location use. `BLOCKED` if infrastructure derives or stores location from IP addresses. | Only declare a purpose actually implemented. | Audit CDN/WAF/host logs and geolocation features. | Depends on final hosting behavior. |

The following user data currently remains on-device and therefore is not reported as collected solely because it exists: calorie/protein goals, selected language, consent state, local diary entries, and recent scan timestamps. Backup/device transfer is disabled. This conclusion must change if sync, support upload, analytics, or cloud backup is added.

## Ephemeral-processing decision

Do **not** mark meal photos or health information as ephemeral yet.

Although the FastAPI route closes `UploadFile` and does not intentionally persist photos, the multipart parser may spool uploads to temporary disk. The external model provider's storage, human-review, abuse-monitoring, training, backup, and deletion behavior is unknown. Google's definition requires memory-only storage for no longer than necessary to fulfill the real-time request.

Mark ephemeral only after all of these have evidence:

- [ ] API ingress, framework, temporary files, retries, queues, logs, traces, and error reporting never retain image bodies.
- [ ] The provider contract and configuration guarantee request-only processing consistent with Google's definition.
- [ ] No failed job, retry store, prompt log, support tool, or backup retains the photo or derived health data.
- [ ] An integration test verifies deletion/absence after success, timeout, cancellation, and provider failure.

## Collection-versus-sharing decision for the model provider

Sending a photo from the first-party API to another organization is collection. Whether it must also be declared as sharing depends on the final relationship. Google excludes a service provider from sharing only when it processes data on the developer's behalf and under the developer's instructions.

- If the vendor is contractually a processor/service provider, uses the data only to return the requested result, and does not train or use it for its own purposes: candidate **collected, not shared**, subject to legal review.
- If the vendor uses data for its own model improvement, advertising, profiling, or another independent purpose: declare **shared** and reassess whether launch is acceptable.
- A user-facing consent screen does not remove the obligation to disclose collection or to explain the processor in the privacy policy.

## Submission blockers

- [ ] Record the exact release flags, AAB checksum, package/version, dependency lockfile, and API base URL.
- [ ] Choose the production vision provider and document its legal entity, role, region, subprocessors, retention, training, and deletion terms.
- [ ] Choose the production host/CDN/WAF and document IP/access-log fields and retention.
- [ ] Decide whether accounts and paid subscriptions ship in the same release.
- [ ] If subscriptions ship, define non-ephemeral token/entitlement retention needed for replay prevention and lifecycle handling; reconcile it with [Play Billing security guidance](https://developer.android.com/google/play/billing/security).
- [ ] Publish and link a compliant public privacy policy in both the app and Play Console.
- [ ] Reconcile this worksheet against the final AAB's SDK inventory and live network captures.
- [ ] Save the completed Play Console form export beside the release evidence and review it whenever code, SDKs, providers, or retention change.
