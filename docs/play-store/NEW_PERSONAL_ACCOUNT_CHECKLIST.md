# New personal Google Play Console account — beta checklist

Status: 22 September 2026. This is an operational checklist for a new personal
account. Google Play policy and the tasks shown in an individual Play Console
can change; the Console's current requirements take precedence.

## Release decision

The current app is suitable only for **internal testing followed by a closed
beta**. Keep `DEMO_MODE=true`: the selected meal photo remains on the device and
the app creates one fixed demonstration meal entirely on-device without an
analysis request. Do not request production access or enable payments merely
because an AAB builds successfully.

A source-code ZIP cannot be uploaded as a Play release. Play requires a signed
Android App Bundle (`.aab`).

## Step-by-step setup

### 1. Create and verify the personal developer account

- [ ] Sign in at [Google Play Console](https://play.google.com/console) with the
  Google account that will remain the account owner.
- [ ] Choose **Personal** only if publishing as an individual. If a registered
  company will own the app, stop and evaluate an Organization account instead.
- [ ] Accept the Developer Distribution Agreement and pay Google's one-time
  **US$25 registration fee** with an accepted card.
- [ ] Complete the payments profile and identity verification with the legal
  name and official government ID requested by Google.
- [ ] Verify the developer email plus the private contact email and phone number
  requested in Console. Review which developer details Google will display.
- [ ] Complete device verification in the Play Console mobile app using a real,
  non-rooted Android phone running Android 10 or later.

Official guidance: [account registration](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en),
[identity and contact verification](https://support.google.com/googleplay/android-developer/answer/10841920?hl=en), and
[device verification](https://support.google.com/googleplay/android-developer/answer/14316361?hl=en).

### 2. Create the Play app record

- [ ] Select **Create app**; choose **App** rather than Game, English (United
  States) as the default language, **Free**, and a monitored support email.
- [ ] Use the **Health & Fitness** category. Add only tags that accurately match
  the initial app experience.
- [ ] Keep the app free to download and later sell optional Pro access through
  in-app subscriptions. Once an app has been offered free, Google does not allow
  that same package to become a paid-download app; this does not prevent Play
  Billing subscriptions or in-app products.
- [ ] Use `MyIdealBody AI Beta` while testing.
- [ ] Confirm the final application ID/package name before the first upload.
  `com.myidealbody.ai` becomes a permanent identity on Play and cannot be reused.
- [ ] Accept the Play App Signing terms and required policy/export declarations.

Official guidance: [create and set up an app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en),
[choose a category and tags](https://support.google.com/googleplay/android-developer/answer/9859673?hl=en), and
[free/paid app pricing rules](https://support.google.com/googleplay/android-developer/answer/6334373?hl=en).

### 3. Produce a beta Android App Bundle

- [ ] Keep `targetSdk` at **API 36 or higher**; this is required for new mobile
  apps submitted after 31 August 2026.
- [ ] Generate a private upload keystore outside the repository. Never commit the
  keystore, `key.properties`, passwords, service-account files, or API keys.
- [ ] Enroll in Play App Signing and sign the upload bundle with the upload key.
- [ ] Increment `versionCode` for every upload.
- [ ] Configure the protected `play-release` GitHub environment and the four
  required `ANDROID_UPLOAD_*` secrets described in `mobile/README.md`. The
  optional `ANDROID_UPLOAD_CERT_SHA256` secret guards against using the wrong
  upload key. `PRODUCTION_API_BASE_URL` is not needed for the local demo.
- [ ] In **Actions > Build signed Play AAB > Run workflow**, select
  `local_demo`, enter version name `0.1.0` and version code `1`, and keep the
  confirmation `LOCAL_DEMO_INTERNAL_OR_CLOSED_TEST`. The workflow runs tests,
  signs the bundle, verifies the signature, and provides the AAB plus its
  SHA-256 checksum as a GitHub Actions artifact retained for seven days. Anyone
  authorized to read this repository's workflow artifacts may download it. It
  does not publish to Google Play.
- [ ] If building locally instead, configure the untracked
  `mobile/android/key.properties` file and build the same fully local demo:

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter build appbundle --release \
  --build-name=0.1.0 \
  --build-number=1 \
  --dart-define=APP_VERSION=0.1.0 \
  --dart-define=DEMO_MODE=true
```

- [ ] Verify the resulting signature. The expected file is
  `mobile/build/app/outputs/bundle/release/app-release.aab`.
- [ ] Install through Play's internal-testing delivery path and test on a real
  device; an AAB is a publishing artifact, not a directly installable ZIP/APK.

Official guidance: [Android App Bundles](https://developer.android.com/guide/app-bundle/),
[target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en), and
[Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756?hl=en).

### 4. Complete the beta store presence

- [ ] Paste the English and Indonesian copy from
  `docs/play-store/LISTING_COPY_EN_ID.md` into separate localized listings.
- [ ] Use English (United States) as the global fallback and publish a manually
  reviewed Bahasa Indonesia listing for Indonesia. Add country-specific custom
  listings only when the marketing content genuinely differs by market.
- [ ] Upload an app icon, feature graphic, and phone screenshots that show the
  word **Beta** and do not suggest that the fixed result came from the photo.
  Ready icon and feature-graphic files are in `store_assets/`; authentic phone
  screenshots must still be captured from the signed release build.
- [ ] Add a monitored support email and a working support website.
- [ ] Host the privacy policy at a public, active, non-geofenced HTML URL. Link
  the same policy in Play Console and inside the app.
- [ ] Keep the health disclaimer in both the listing and app.

Official guidance: [store listing setup](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en) and
[review preparation](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en).

### 5. Complete every App content declaration truthfully

- [ ] **App access:** explain the no-login beta path or provide durable reviewer
  credentials if authentication is later added.
- [ ] **Ads:** declare no ads only if the shipped app and all SDKs truly show none.
- [ ] **Target audience:** use an adult test audience for this release; do not
  market the nutrition beta to children.
- [ ] Complete the content-rating questionnaire and permissions declarations.
- [ ] **Health Apps:** select **Health and fitness > Nutrition and weight
  management** and state that outputs are general-wellness estimates.
- [ ] **Data Safety:** audit the exact AAB and every SDK. In the current safe
  demo, the selected photo remains on-device and demo analysis and billing make
  no request. Verify this with a network capture. Do not declare
  a planned production upload as current behavior, and do not omit any actual
  off-device collection. On-device-only processing is not declared as collected;
  off-device transmission is, even when processing is ephemeral.
- [ ] If a later version transmits meal photos, update the privacy policy,
  consent flow, Data Safety answers, retention/deletion practice, and processor
  disclosures **before uploading that version**.
- [ ] If account creation is introduced, add both an in-app account-deletion path
  and a public web deletion-request URL before release.
- [ ] Use only necessary camera/photo access, provide a clear purpose before the
  request, and handle denial without crashing.

Official guidance: [Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en),
[User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en),
[account deletion](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en),
[Health Apps declaration](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en), and
[Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en).

### 6. Run internal testing first

- [ ] Upload the signed AAB to **Internal testing** and add a small trusted group.
- [ ] Test camera, gallery, denied permission, offline/retry, low-memory devices,
  English/Indonesian, large text, TalkBack, diary deletion, and demo disclosure.
- [ ] Run the Play pre-launch report; resolve crashes, ANRs, broken links, policy
  warnings, and material accessibility failures.
- [ ] Confirm that subscriptions cannot start and no screen promises genuine AI
  analysis in this demo build.

### 7. Run the required closed test conservatively

Assume the new-personal-account rule applies unless Play Console explicitly says
otherwise.

- [ ] Create a **Closed testing** track and invite more than 12 suitable testers
  so the test remains above the minimum if someone leaves.
- [ ] Maintain at least **12 testers continuously opted in for 14 consecutive
  days**. A tester who opts out does not count; opting back in restarts that
  tester's continuous period.
- [ ] Ask testers to exercise real beta flows and retain a feedback log covering
  devices, bugs, usability, disclosure clarity, and changes made.
- [ ] Do not submit a fixed demo to production after the clock completes. The
  12/14 threshold unlocks an application for production access; it is not a
  quality, policy, or AI-readiness approval.

Official guidance: [testing requirements for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

### 8. Keep billing disabled during this beta

- [ ] Do not sell Pro access until user authentication, backend purchase-token
  verification, acknowledgement, entitlement restore, cancellations/refunds,
  and Play real-time notifications are complete and tested.
- [ ] Future in-app sales of digital Pro functionality must use Google Play
  Billing unless an applicable enrolled regional program permits another flow.
- [ ] Use a currently supported Play Billing Library. Version 7 passed its normal
  new-app/update deadline on 31 August 2026; use version 8 or newer rather than
  relying on a temporary extension.
- [ ] For production, configure Play-localized prices and show the exact
  `ProductDetails` price and period: planned Indonesia monthly Rp49,000;
  international starting references about US$4.99/month and US$19.99/year.

Official guidance: [payments policy](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en),
[Play Billing](https://developer.android.com/google/play/billing/), and
[Billing Library support timeline](https://developer.android.com/google/play/billing/deprecation-faq).

### 9. Production gate — do not cross yet

Apply for production access only after the closed-test requirement is met **and**
all of the following are verified:

- [ ] A real food-recognition provider is enabled and fails safely.
- [ ] Nutrition data has documented commercial reuse rights and provenance.
- [ ] Representative Indonesian-meal evaluation supports every accuracy claim.
- [ ] Users can correct recognized foods, portions, and important assumptions.
- [ ] Production HTTPS backend, quotas, abuse protection, monitoring, support,
  incident handling, privacy, and deletion flows are operational.
- [ ] The production AAB's Data Safety, Health Apps, privacy, permission, and
  billing declarations match its actual behavior.
- [ ] Production listing copy removes the fixed-demo notice but continues to call
  nutrition outputs estimates and retains the medical disclaimer.

When eligible, Play Console asks about tester engagement, feedback, changes, the
app's audience/value, and production readiness. Google states that production-
access review usually takes seven days or less but can take longer. Approval to
access production still does not publish the app automatically; review the final
release and use a staged rollout.
