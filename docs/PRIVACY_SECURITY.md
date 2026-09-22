# Privacy and security baseline

This is the implementation baseline for the MVP, not a substitute for a lawyer-reviewed public privacy notice. Review Indonesia's [Personal Data Protection Law (Law No. 27 of 2022)](https://peraturan.bpk.go.id/Details/229798/uu-no-27-tahun-2022) and every market in which the app is offered.

## Product promises

- A meal photo is used only to return the requested nutrition estimate unless the user separately opts in to save it or contribute it to model improvement.
- Raw photos, nutrition history, goals, and derived health data are never sold, used for behavioral advertising, or provided to ad networks.
- Training/research consent is separate, optional, specific, revocable for future use, and off by default. Consent to analyze a photo is not consent to train on it.
- Users can use the core scan flow with the minimum data necessary. Optional analytics and marketing choices do not block core use.
- Estimates are not medical advice and are not represented as measurements or diagnoses.

Google treats health-app data as sensitive and requires accurate disclosure, a public privacy policy, minimal permissions, and the Health Apps declaration. See [Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en-sg) and [Data Safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN).

## Data inventory and default retention

These are product targets; configure automated deletion and verify it with tests before publishing.

| Data | Purpose | Default retention |
|---|---|---|
| Camera/gallery image | Recognize foods and portions | Delete from processing storage after the result, with a hard maximum of 24 hours for failed jobs/retry |
| User-saved meal image | Show the diary photo | Until that meal/account is deleted; saving is an explicit choice |
| Derived foods, portions, calories, protein, confidence | Result and diary | Until the meal/account is deleted |
| Goal/profile data | Personal daily targets | Until changed or account deletion |
| Account ID/email | Sign-in, sync, support | Until account deletion, then remove from active systems promptly |
| Purchase token and entitlement | Verify Pro access and prevent replay | Active entitlement plus a documented fraud/dispute window; retain only legally required transaction records after that |
| Operational/security logs | Reliability, abuse, incident response | 30 days normally; up to 90 days for security events, without image bodies or nutrition payloads |
| Support messages | Resolve user requests | 12 months, then delete or anonymize unless an open dispute requires longer |
| Backups | Disaster recovery | Encrypted, access-controlled, rolling expiry no longer than 30 days; deleted data must not return to live systems |

Do not collect precise location, contacts, advertising ID, microphone, or broad storage access for the MVP. Strip EXIF metadata before upload and do not store the original filename.

## Consent and user controls

- Before the first upload, explain in English/Indonesian what is sent, why, whether a model provider processes it, the default deletion period, and where the policy is available. Ask for an affirmative action.
- Request camera permission only after the user chooses camera capture. Denial must leave gallery/manual flows usable where technically possible.
- Provide Settings actions to delete a meal, clear history, export data, withdraw optional training/analytics consent, manage the subscription, and delete the account.
- If account creation exists, provide an in-app deletion path and a public web deletion-request page. The web flow must work without reinstalling the app. Google documents both requirements in its [account deletion guidance](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en-AU).
- Tell users what is deleted, what must be retained, why, and the expected completion time. Propagate deletion to processors and prevent restoration from backups.

## Secure architecture

### Mobile

- Keep API/provider secrets out of the APK. Store session credentials in Android Keystore-backed secure storage.
- Disable cleartext traffic; use TLS and certificate/hostname validation. Do not implement permissive trust managers.
- Put captures in app-private temporary storage, remove them after upload/result, and exclude sensitive caches from backup.
- Validate server certificates and API response schemas; handle replayed/deep-linked screens without exposing another user's meal.
- Use the Android Photo Picker for existing images and request no permission that the active build does not use.

### API and storage

- Authenticate every diary/export/delete request and enforce object-level authorization; test cross-account IDs explicitly.
- Encrypt in transit and at rest. Use a managed secret store and key rotation, not `.env` files in production images.
- Use private object storage with short-lived signed access. Block public buckets and log administrative reads.
- Limit image bytes, dimensions, MIME types, decompression ratio, and processing time. Decode and re-encode safely; ignore user filenames and metadata.
- Rate-limit by account and risk signals, add request IDs, and ensure logs redact authorization headers, purchase tokens, images, prompts, and nutrition records.
- Separate production/staging data. Require MFA, least-privilege roles, reviewed access, and an auditable break-glass process.
- Keep model-provider data retention and training disabled by contract/configuration. Maintain a current processor/subprocessor register and regional-transfer assessment.

### Billing

- Send purchase tokens only to the backend over authenticated TLS. Verify them with Google, bind them to an obfuscated account ID, reject token reuse, and grant access only after a valid `PURCHASED` response.
- Acknowledge valid purchases promptly, process Real-time Developer Notifications idempotently, and reconcile status periodically. See [Play Billing security guidance](https://developer.android.com/google/play/billing/security).

## Threat and release checklist

- [ ] Data-flow diagram and inventory match code and all SDKs.
- [ ] Data Safety answers match production behavior, including ephemeral uploads and processors.
- [ ] No raw image, health payload, access token, or purchase token appears in logs, analytics, crash reports, or support tooling.
- [ ] Authorization tests cover read/update/delete/export across two different accounts.
- [ ] Upload tests cover oversized files, malformed images, decompression bombs, duplicate requests, and timeouts.
- [ ] Rate limits and spend caps protect scan, login, export, and deletion endpoints.
- [ ] Dependencies, container images, and mobile SDKs are scanned and patched; a software bill of materials is retained per release.
- [ ] Restore and deletion jobs are exercised in staging, including processor deletion and backup expiry.
- [ ] Incident runbook names an owner, severity levels, containment steps, provider contacts, evidence retention, user/regulator notification assessment, and key rotation procedure.
- [ ] Privacy/security contact and vulnerability-reporting channel are monitored.

## Provider review questions

Before sending photos to any vision/model vendor, document: processing region; storage duration; training default; opt-out enforcement; subprocessors; encryption; deletion API; incident notice; access controls; audit reports; and whether prompts/images can be inspected by humans. If the answers cannot meet the promises above, do not use that provider in production.
