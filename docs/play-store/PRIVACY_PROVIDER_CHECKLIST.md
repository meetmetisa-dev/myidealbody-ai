# Privacy and model-provider launch checklist

Status: **release gate**  
Prepared: 22 September 2026

This checklist prevents the safe demo build and a future real-photo build from being described as if they had the same data flow.

## 1. Freeze the release mode

Record these facts for every AAB:

- [ ] Git commit and clean-worktree evidence.
- [ ] Signed AAB path, SHA-256, version code, and version name.
- [ ] `DEMO_MODE` value used at compilation.
- [ ] `API_BASE_URL` used at compilation; record `not used` for the local demo, while production must use the fixed HTTPS origin.
- [ ] Backend environment and `VISION_PROVIDER` value.
- [ ] Nutrition catalog version, sources, licenses, and provenance.
- [ ] Dependency/SDK inventory from the final AAB.

### Actual behavior comparison

| Step | `DEMO_MODE=true` now | `DEMO_MODE=false` future production |
|---|---|---|
| User chooses a photo | Camera/photo-picker file is used for preview only | File is also read for upload |
| Bytes sent by app | None for analysis | Selected JPEG/PNG/WebP, renamed to a generic upload filename |
| Client metadata handling | Selected bytes are not transmitted | The client does not yet guarantee full re-encoding/EXIF removal before the first-party API receives the file |
| API handling | No analysis request | Validates bytes; provider adapter transposes, resizes to ≤1600×1600, and re-encodes as JPEG before the external provider call |
| Recognition | Fixed `mock_demo` plate created in the app | Configured external vision model |
| On-device result | Fixed sample cannot be saved and does not consume scan allowance | User-specific estimate may be saved locally |
| Photo persistence | Camera temporary file is deleted on failure, retake, or save; gallery source is not deleted by the app | Same local behavior; server/provider retention remains `BLOCKED` |

Relevant implementation: [`api_service.dart`](../../mobile/lib/services/api_service.dart), [`scan_screen.dart`](../../mobile/lib/screens/scan_screen.dart), [`result_screen.dart`](../../mobile/lib/screens/result_screen.dart), [`analysis.py`](../../backend/app/routes/analysis.py), and [`openai_compatible.py`](../../backend/app/providers/openai_compatible.py).

## 2. Public privacy policy

The public policy must match the selected release mode and contain:

- [ ] App name, publishing legal entity, contact method, effective date, and change history.
- [ ] Exact data accessed on-device: camera/gallery photo, locale, goals, diary, consent, and scan timestamps.
- [x] Exact data sent off-device for demo analysis: none; the fixed sample is generated entirely on-device.
- [ ] Exact data sent off-device in production: selected photo, locale, source, and any authentication/quota identifiers.
- [ ] Derived data handled by the API: food IDs, estimated grams, calories, macros, confidence, caveats, and analysis ID.
- [ ] Purpose for every data type; no broad “improve services” purpose unless that secondary use genuinely exists and has an appropriate consent/legal basis.
- [ ] All recipients/processors, processing countries/regions, and cross-border transfer basis.
- [ ] Retention for successful requests, failed requests, temporary files, logs, backups, purchase tokens, support data, and deletion requests.
- [ ] A clear statement that analysis consent is not consent for model training; training must remain off unless separately and explicitly opted in.
- [ ] User controls for cloud analysis, deleting local history, deleting server data, withdrawing optional consent, and contacting support.
- [ ] Security summary, including TLS, access controls, and incident contact, without promising absolute security.
- [ ] General-wellness and non-medical disclaimer.
- [ ] A prominent account/data-deletion section if accounts or server retention ship.
- [ ] English and Bahasa Indonesia text reviewed for substantive parity.

Google requires the policy in Play Console and within the app. For a health app it must be a public, active, non-geofenced, non-editable web page rather than only a PDF. Settings now links to the GitHub Pages policy, terms, and support pages; verify those exact URLs are live and match the AAB before submission. Recheck the final text against Google's [User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en) and [Health Content and Services policy](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en).

## 3. First-upload disclosure and consent

Before a real photo leaves the device, show concise English/Indonesian text that identifies:

- [ ] what is sent (one selected meal photo plus request fields);
- [ ] why it is sent (food/portion recognition and nutrition estimation);
- [ ] the first-party API and external model provider by legal name;
- [ ] whether either party stores, reviews, or trains on the photo;
- [ ] the deletion/retention period; and
- [ ] links to the full privacy policy and an affirmative Continue/Cancel choice.

Do not reuse the current future-tense demo wording for a production build. Consent must reflect deployed facts.

## 4. Vision-provider due diligence

Complete this table and attach source documents or contract sections. Any unresolved red item blocks production uploads.

| Question | Required evidence | Status |
|---|---|---|
| Provider and contracting legal entity | Contract/order form and privacy/DPA links | `BLOCKED` |
| Role: processor/service provider or independent third party | Signed DPA and processing instructions | `BLOCKED` |
| Processing and storage regions | Region configuration plus contractual commitment | `BLOCKED` |
| Image/prompt/output retention | Exact duration for success, error, abuse review, logs, and backups | `BLOCKED` |
| Model training/product improvement | Contractual no-training term and account setting screenshot | `BLOCKED` |
| Human access/review | Purpose, access roles, frequency, opt-out, and audit trail | `BLOCKED` |
| Subprocessors | Current list plus change-notice process | `BLOCKED` |
| Encryption and key management | TLS version and at-rest controls | `BLOCKED` |
| Deletion | API/process, propagation to replicas/backups, and completion SLA | `BLOCKED` |
| Security assurance | Relevant audit reports/certifications and penetration-test summary | `BLOCKED` |
| Incident notice | Contractual notice time and contact path | `BLOCKED` |
| Availability, quotas, and spend caps | SLO, timeout/retry rules, hard budget alert/cap | `BLOCKED` |
| Content safety and model limitations | Documented behavior and representative Indonesian-food evaluation | `BLOCKED` |

Do not put the provider API key in the APK or website. It belongs in a managed backend secret store.

## 5. Backend and infrastructure verification

- [ ] Public API uses HTTPS only; release mobile build has no cleartext exception.
- [ ] CORS is limited to approved browser origins; CORS is not treated as authentication.
- [ ] User authentication, per-user authorization, quotas, rate limits, idempotency, and cost-abuse controls are implemented before public paid analysis.
- [ ] CDN/WAF/load-balancer/application logs are inventoried field by field; images, request bodies, authorization headers, purchase tokens, prompts, and health results are excluded.
- [ ] IP-address handling, geolocation inference, retention, and operator access are documented for Data Safety.
- [ ] Upload bodies cannot persist in parser spool files, queues, crash dumps, traces, retries, or backups beyond the disclosed period.
- [ ] Success, invalid file, provider timeout, cancellation, disconnect, and crash paths are tested for cleanup.
- [ ] Provider and catalog startup checks fail closed in production.
- [ ] An incident-response owner, support contact, provider escalation path, and key-rotation runbook exist.

## 6. Billing and account boundary

Current code cannot safely enable purchases: the app has no user authentication and the backend endpoint expects an internal bearer token that must never be embedded in an APK.

Before enabling subscriptions:

- [ ] Implement user/session authentication and bind entitlements to a user record or a reviewed accountless entitlement design.
- [ ] Declare purchase history and any user identifier in Data Safety as implemented.
- [ ] Verify purchase tokens server-side, prevent replay, acknowledge purchases, and process renewals/refunds/revocations.
- [ ] Define purchase-token and transaction retention.
- [ ] Provide restore and manage/cancel flows and test them with Play license accounts.
- [ ] If users can create accounts anywhere, implement a discoverable in-app deletion path and a public web deletion resource. Google's [account-deletion guidance](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en) requires deletion of associated user data, including at processors, subject to clearly disclosed lawful retention.

## 7. Final release reconciliation

- [ ] Network-capture the final release through onboarding, camera, gallery, analysis success/failure, diary, settings, paywall, purchase, restore, and manage-subscription flows.
- [ ] Compare every destination and field with the privacy policy, Data Safety draft, Health Apps declaration, consent screen, and store listing.
- [ ] Review the final AAB with Play SDK Index/dependency reports for undisclosed SDK behavior.
- [ ] Re-run the audit whenever a provider, host, SDK, permission, account feature, analytics tool, retention period, or data use changes.
- [ ] Obtain owner approval before submitting any declaration; these drafts intentionally leave unknown facts blocked.
