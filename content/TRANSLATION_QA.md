# Translation QA Checklist

Run this checklist for English, Bahasa Indonesia, and every future locale before release. Test with production-like data, not only short placeholder values.

## Language and meaning

- [ ] Every user-facing string is localized; no raw keys or unexpected English appear in Indonesian.
- [ ] The selected voice is consistent: Indonesian uses friendly **kamu**, not a mix of *Anda*, *kamu*, and *kalian*.
- [ ] “Estimate,” uncertainty ranges, confidence, and limitations remain explicit.
- [ ] No copy labels food or behavior as good/bad, clean/dirty, success/failure, cheating, or guilt-worthy.
- [ ] Local food names are natural and searchable; protected dish names are not translated literally.
- [ ] Calories, protein, carbs, fat, fiber, portions, oil, santan, and sugar use the approved glossary.
- [ ] Medical, allergen, privacy, billing, and deletion copy matches actual product behavior and has the required review.

## Variables and plurals

- [ ] All placeholders render, with no `{name}` tokens visible to the user.
- [ ] Placeholder order can change without concatenating sentence fragments.
- [ ] Test counts `0`, `1`, `2`, `10`, `1,000`, and a very large value.
- [ ] ICU plurals/selects compile and use the locale’s correct forms.
- [ ] Long food names, user names, and translated plan names do not overlap controls.
- [ ] Model-provided food names are escaped and do not break layout or accessibility output.

## Locale formatting

- [ ] Numbers use locale separators (`1,250.5` in English; `1.250,5` in Indonesian where decimals are shown).
- [ ] Dates, weekdays, times, and time zones use locale-aware formatters.
- [ ] Google Play supplies the displayed price and billing period; `$`, `Rp`, and converted prices are not hardcoded.
- [ ] Test monthly, annual, introductory, pending, canceled, restored, and unavailable billing states.
- [ ] `kcal`/`kkal`, grams, teaspoons, tablespoons, bowls, plates, and pieces display consistently.
- [ ] Numeric ranges use the correct order and an en dash, and screen readers announce them understandably.

## Layout and interaction

- [ ] Test small and large Android phones in portrait and landscape where supported.
- [ ] Test default, 130%, and 200% system font sizes without clipped text or hidden actions.
- [ ] Buttons tolerate at least 50% text expansion.
- [ ] Camera hints remain readable over light and dark food photos and are announced by TalkBack.
- [ ] Dialogs scroll when content is long; the confirm and cancel actions stay reachable.
- [ ] Text wrapping does not separate numbers from units or obscure prices.
- [ ] Icons, photos, charts, and controls have localized accessibility labels.
- [ ] Focus order is logical with TalkBack, including photo review and correction controls.
- [ ] Color is not the only cue for confidence, errors, targets, or subscription selection.

## Key journeys

- [ ] Complete onboarding and switch language both before and after onboarding.
- [ ] Grant, deny, and permanently deny camera permission; verify gallery fallback copy.
- [ ] Capture clear, dark, blurry, partial, non-food, oversized, and unsupported images.
- [ ] Review high-, medium-, and low-confidence results and explain the estimate range.
- [ ] Answer and skip oil, santan, sugar, sauce, and cooking-method follow-ups.
- [ ] Add, rename, resize, and delete a recognized food; add a custom food manually.
- [ ] Save, edit, copy, delete, and undo deletion of a diary meal.
- [ ] Exercise offline, timeout, server, upload, authentication, and quota errors.
- [ ] Purchase, cancel, defer/pending, restore, expire, and manage a subscription in Play test mode.
- [ ] Export data, start account deletion, manage an active subscription, confirm deletion, and handle deletion failure.

## Future locales

- [ ] A native reviewer checks meaning, tone, food terminology, and cultural fit in context.
- [ ] Pseudolocalization finds hardcoded text, truncation, and concatenation problems.
- [ ] Right-to-left locales mirror navigation and layout without reversing numbers or food photos.
- [ ] A fallback locale is defined and missing translations are reported in CI.
- [ ] Store listing, screenshots, privacy pages, emails, notifications, and support content use the same glossary as the app.
- [ ] Analytics use stable event/property IDs, not localized display strings.

## Release sign-off

- [ ] Product verifies that copy reflects shipped features and limits.
- [ ] Engineering verifies placeholders, formats, fallback behavior, and Play Billing values.
- [ ] Nutrition review verifies food and unit terminology.
- [ ] Privacy/legal review verifies consent, retention, account deletion, billing, health, and allergen language.
- [ ] A native English reviewer and a native Indonesian reviewer approve the final build screenshots.
