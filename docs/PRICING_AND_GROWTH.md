# Pricing and growth plan

## Decision

The proposed **Rp49,000 monthly price is a good Indonesian launch price**. US$20 is too high **per month** for a new self-service calorie tracker without an established coaching service. US$19.99 works much better as an introductory **annual** price.

| Tier | Indonesia | International reference | Entitlement |
|---|---:|---:|---|
| Free | Rp0 | US$0 | 3 completed analyses per local calendar day, manual correction, 7-day diary |
| Pro monthly | Rp49,000/month | US$4.99/month | Higher fair-use limit, full history, trends, priority processing |
| Pro annual launch | Rp299,000/year | US$19.99/year | Same Pro features; early-market acquisition price |

“International reference” is a Play Console base/reference price, not a promise that every market pays an identical conversion. Set an explicit IDR price for Indonesia and review Play's generated country prices. Google Play shows a supported local currency and handles currency conversion; see [Play's multiple-currency guidance](https://support.google.com/googleplay/android-developer/answer/1169947?hl=en-EN) and [price setup guidance](https://support.google.com/googleplay/android-developer/answer/6334373?hl=en-ID).

## Guardrails

- Use two products/base plans, for example `pro_monthly` and `pro_annual`. The app must render the price and billing period returned by Play.
- Treat Rp299,000 / US$19.99 annual as a launch hypothesis. It discounts heavily versus monthly, so validate retention and inference cost before making it permanent.
- Do not advertise a fake crossed-out price. If a discount renews at another price, disclose the offer duration and renewal price next to the purchase button.
- Avoid “unlimited” while inference has a real marginal cost. Start with a generous fair-use limit, such as 30 analyses/day, and explain it plainly.
- Keep the free allowance usable without payment details. Rate-limit by account/device signals to reduce abuse without collecting excessive identifiers.
- Never personalize price or advertising from meal, weight, calorie, protein, or other health-related data.

## Unit-economics gate

For each plan and country, track:

`contribution = net Play proceeds - model/API cost - storage/egress - support/refund allowance`

Approve a price only after measuring real image-processing cost, retries, free usage, tax treatment, Play fees, refund rate, and monthly churn. Do not calculate margin from list price alone.

## The competitive wedge

Trying to be a generic MyFitnessPal clone is unlikely to win. Lead with one memorable promise: **the fastest protein and calorie estimate for everyday Indonesian meals, with uncertainty users can correct**.

Build the moat in this order:

1. **Indonesian food depth:** warteg portions, nasi Padang components, gorengan, sambal, santan, sauces, common branded foods, and household measures.
2. **Trust over false precision:** calorie/protein ranges, confidence, visible assumptions, and quick questions for hidden oil, sugar, sauce, or coconut milk.
3. **Correction loop:** one-tap item, portion, and cooking-method edits; use consented corrections to improve the catalog and evaluation set.
4. **Protein-first workflow:** daily protein remaining, meal-level protein, and affordable Indonesian protein suggestions. Avoid medical or guaranteed-outcome claims.
5. **Local experience:** natural English and Bahasa Indonesia, grams plus household units, low-bandwidth behavior, and responsive local support.

## First experiments

Run one material change at a time, predefine the success metric, and keep a holdout where practical.

| Experiment | Variants | Primary decision metric | Safety metric |
|---|---|---|---|
| Onboarding promise | “Hit your protein” vs “Log meals faster” | First successful scan | Onboarding completion |
| Free allowance | 3 vs 5 scans/day | 14-day paid conversion | D7 retention and inference cost |
| Paywall plan order | Annual-first vs monthly-first | Revenue per paywall viewer | Refund and cancellation rate |
| Result experience | Point estimate vs range-first | Saved meals after correction | Correction rate and trust survey |
| Annual price | Rp299k vs a higher new-user offer | 60-day revenue per eligible user | Conversion and early refund rate |

Use Play subscription offers or country prices for actual billing tests. Do not merely change a hard-coded paywall label.

## Growth loops

- Recruit the first 50–100 testers from Indonesian gym, dietitian, and meal-prep communities; ask them to scan their real meals, not a scripted demo.
- Publish short “AI estimate vs weighed meal” evaluations, including misses. Transparent benchmarks build more trust than accuracy slogans.
- Let users share a clean meal card without personal goals or health history; add a referral reward only after paid retention is acceptable.
- Partner with credible Indonesian nutrition professionals for content review and meal-dataset labeling. Do not imply clinical endorsement without written permission.
- Build searchable landing pages for common local dishes only from licensed nutrition content; route users to the app for personalized logging.

## Weekly scorecard

Track first-scan completion, analysis latency/failure, meals saved, correction rate, D1/D7/D30 retention, free-to-paid conversion, trial-to-paid conversion if trials are introduced, monthly churn, refunds, support contacts per 1,000 users, and inference cost per active/paid user. Segment by locale, device class, acquisition source, and plan—not by sensitive health traits for advertising.

The first proof point is not downloads. It is a retained cohort that repeatedly logs Indonesian meals, corrects few results over time, and produces positive contribution after inference cost.
