# Google Play launch checklist

Status: 19 September 2026. Google Play policy changes frequently; recheck Policy status and App content in Play Console before every release.

## Release gates

### 1. Build and signing

- [x] Permanent package/application ID confirmed and CI-locked as `com.myidealbody.ai`; do not change it after the first Play registration or upload.
- [ ] Build an Android App Bundle (`.aab`), enroll in Play App Signing, and keep the upload key backed up.
- [ ] Configure the protected `play-release` GitHub environment and signing secrets, then run **Build signed Play AAB** from `main`. The source ZIP is not accepted by Play.
- [ ] Set `targetSdk` to **36 or higher**. Since 31 August 2026, new mobile apps and updates must target Android 16 / API 36. Do not plan around the temporary extension. See [Google Play's target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en).
- [ ] Increment `versionCode` for every upload and use a human-readable `versionName`.
- [ ] Request only permissions used by the shipped build. The MVP should need camera and network access; use Android Photo Picker instead of broad storage access.
- [ ] Test release builds on low-, mid-, and high-range Android devices, slow networks, denied camera permission, airplane mode, and process recreation.

### 2. Test track

- [ ] Start with internal testing, then a closed test.
- [ ] For the default `local_demo` AAB, use only Internal or Closed Testing and the exact confirmation `LOCAL_DEMO_INTERNAL_OR_CLOSED_TEST`; do not describe or submit it as production photo recognition.
- [ ] If the Play Console account is a **personal account created after 13 November 2023**, keep at least **12 testers opted in continuously for 14 days**, then apply for production access. This rule is account-specific, not universal. Keep feedback and a record of changes for the application. See [Google Play's testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-EN).
- [ ] Give reviewers working credentials or a no-login review path under App access.
- [ ] Run the Play pre-launch report and fix crashes, ANRs, accessibility blockers, and broken links.

### 3. Store listing

- [ ] Create English and Indonesian listings, screenshots, icon, feature graphic, short description, and support contact.
- [ ] Describe the product as an **estimate**, not a calorie measurement. State that portions, oil, coconut milk, sugar, sauces, and mixed dishes may need correction.
- [ ] Include this health disclaimer in the listing and app: “This app is not a medical device and does not diagnose, treat, cure, or prevent any medical condition. Consult a qualified healthcare professional for medical advice.” Google requires a disclaimer for non-medical-device health apps; see [Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en-sg).
- [ ] Say that a camera-capable Android device is needed for photo scanning and provide manual editing when recognition fails.
- [ ] Complete the target audience, content rating, ads, and app access sections accurately.

### 4. Health Apps declaration

- [ ] Complete the Health Apps declaration under **Policy > App content**. Every published app must complete it, including closed/open/production tracks.
- [ ] Select **Health and fitness > Nutrition and Weight Management**. Google explicitly includes dietary intake, meal planning, diets, and weight-management tools in this category. See [Health Apps declaration guidance](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en).
- [ ] Do not claim diagnosis, treatment, clinical accuracy, or guaranteed weight loss.
- [ ] Link the same current privacy policy in Play Console and in the app. It must be public, active, non-geofenced, non-editable by visitors, and served as a web page rather than a PDF.

### 5. Data Safety and deletion

- [ ] Audit the release build and every SDK before answering Data Safety. All apps on closed, open, or production tracks must submit the form; third-party SDK collection counts. See [Data Safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN).
- [ ] Likely declarations include photos/videos when a meal image leaves the device, health and fitness data for nutrition logs/goals, user IDs or email if accounts exist, purchase information, app interactions, diagnostics, and device identifiers if analytics or crash SDKs collect them. Confirm actual behavior rather than copying this list.
- [ ] Declare an uploaded photo even when the server processes it ephemerally. Use the form's ephemeral-processing option only when it is held in memory no longer than needed for the request.
- [ ] Ensure the form, privacy policy, consent screens, SDK behavior, and deletion behavior agree.
- [ ] If users can create an account anywhere in the product, provide both an easy in-app deletion path and a public web page that can initiate deletion without reinstalling the app. Delete associated data from processors too, subject only to disclosed lawful retention. See [Google Play's account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en-AU).

### 6. Subscriptions

- [ ] Sell digital Pro access through Google Play Billing unless a country-specific program clearly permits another flow.
- [ ] Create monthly and annual subscription products/base plans in Play Console. Configure Indonesia prices explicitly; let Play show the buyer's supported local currency elsewhere. Google documents that customers see and pay in local currency where supported: [multiple-currency guidance](https://support.google.com/googleplay/android-developer/answer/1169947?hl=en-EN).
- [ ] Display `ProductDetails` title, price, billing period, offer terms, renewal, and trial information from Play—not hard-coded prices.
- [ ] Provide **Restore purchases** and a **Manage subscription** deep link. Users must be able to cancel through Play; see [subscription management](https://developer.android.com/google/play/billing/manage-purchases).
- [ ] Send purchase tokens to the backend. Verify tokens with `purchases.subscriptionsv2.get`, reject replayed tokens, grant access only for `PURCHASED`, and acknowledge promptly. Google recommends backend verification and acknowledgement: [Play Billing security](https://developer.android.com/google/play/billing/security).
- [ ] Process renewals, grace periods, account hold, cancellation, expiry, revocation, and refunds via Real-time Developer Notifications plus periodic reconciliation.
- [ ] Test licensed accounts, pending payment, renewal, cancellation, restore, refund, offline startup, and reinstall before production.

## Recommended submission order

1. Freeze data flows and SDKs; finish privacy, deletion, and consent surfaces.
2. Create Play subscriptions and connect license-test accounts.
3. Upload the signed AAB to internal testing and complete App content forms.
4. Run the closed test, record feedback, and resolve critical defects.
5. Submit production access if the account-specific test rule applies.
6. Roll out to 5%, monitor crash-free users, analysis failure rate, purchase errors, refunds, and support; then expand gradually.

## Launch blockers

Do not submit until production API credentials, a public privacy-policy URL, a public deletion URL, server-side purchase verification, nutrition-data usage rights, and an incident/support contact are in place. This checklist is operational guidance, not legal advice.

The current manual workflow can safely produce a signed, fully local fixed-result
demo for Internal or Closed Testing after the upload-key secrets are configured.
A successful AAB build is not authorization for a public production rollout.
The `production_photo` mode remains blocked on client-side image re-encoding/EXIF
removal, a final provider/hosting/privacy review, live-policy verification,
licensed nutrition data, authenticated billing/quota controls, and device tests.
