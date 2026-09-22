# MyIdealBody AI — English / Bahasa Indonesia UI Copy

This is the source-of-truth copy deck for the first release. English (`en`) is the fallback locale and Indonesian (`id`) uses a friendly, respectful **kamu** voice. Nutrient values are always presented as estimates, never as medical measurements.

## Voice and terminology

- Clear, calm, practical, and non-judgmental.
- Prefer short verbs on controls: **Take photo / Ambil foto**, **Save / Simpan**, **Edit / Ubah**.
- Never label food as “good,” “bad,” “clean,” “cheat,” or “guilty.”
- Say **estimate / estimasi** wherever image analysis could otherwise appear exact.
- The app may encourage consistency, but must not shame users for missed goals or meals.

## Global and navigation

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `appName` | MyIdealBody AI | MyIdealBody AI | Do not translate the brand name. |
| `navHome` | Home | Beranda | Bottom navigation. |
| `navScan` | Scan | Foto | “Foto” is more natural than “Pindai” for this action. |
| `navDiary` | Diary | Catatan | Food diary. |
| `navInsights` | Insights | Wawasan | Optional post-MVP navigation. |
| `navProfile` | Profile | Profil | Account/settings area. |
| `actionContinue` | Continue | Lanjut | Primary action. |
| `actionBack` | Back | Kembali | Navigation action. |
| `actionCancel` | Cancel | Batal | Dismiss without saving. |
| `actionClose` | Close | Tutup | Close a sheet or dialog. |
| `actionSave` | Save | Simpan | Save current changes. |
| `actionDone` | Done | Selesai | Finish a completed flow. |
| `actionEdit` | Edit | Ubah | Use for correcting food or portions. |
| `actionDelete` | Delete | Hapus | Destructive action. |
| `actionRetry` | Try again | Coba lagi | Recoverable error action. |
| `actionLearnMore` | Learn more | Pelajari lebih lanjut | Opens supporting explanation. |
| `labelCalories` | Calories | Kalori | Use `kcal` for the unit. |
| `labelProtein` | Protein | Protein | Use `g` for the unit. |
| `labelCarbs` | Carbs | Karbohidrat | Prefer the full Indonesian term. |
| `labelFat` | Fat | Lemak | Nutrient label. |
| `labelFiber` | Fiber | Serat | Nutrient label. |
| `labelEstimate` | Estimate | Estimasi | Badge for model-generated values. |
| `labelServing` | Serving | Porsi | Generic serving label. |
| `labelTotal` | Total | Total | Nutrient total. |

## Onboarding

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `onboardingWelcomeTitle` | Know what’s on your plate | Kenali isi piringmu | Main welcome headline. |
| `onboardingWelcomeBody` | Take a photo to estimate calories and protein, then adjust the result in seconds. | Foto makananmu untuk memperkirakan kalori dan protein, lalu sesuaikan hasilnya dalam hitungan detik. | Keep “estimate” explicit. |
| `onboardingPhotoTitle` | One photo, a useful starting point | Satu foto, awal yang praktis | Benefit slide. |
| `onboardingPhotoBody` | We identify likely foods and portions. You stay in control of every result. | Kami mengenali kemungkinan jenis makanan dan porsinya. Kamu tetap memegang kendali atas setiap hasil. | Avoid implying perfect recognition. |
| `onboardingLocalTitle` | Made for everyday meals | Cocok untuk makanan sehari-hari | Localization slide. |
| `onboardingLocalBody` | From nasi Padang and warteg meals to home cooking, you can correct local dishes and ingredients. | Dari nasi Padang dan menu warteg hingga masakan rumahan, kamu bisa mengoreksi hidangan dan bahan lokal. | Indonesia-specific promise. |
| `onboardingGoalTitle` | What would you like to focus on? | Apa fokusmu? | Goal selection. |
| `onboardingGoalCalories` | Understand my calories | Memahami asupan kalori | Goal card. |
| `onboardingGoalProtein` | Reach my protein target | Mencapai target protein | Goal card. |
| `onboardingGoalBalanced` | Build balanced habits | Membangun kebiasaan seimbang | Goal card. |
| `onboardingGoalNoPressure` | You can change this anytime. There’s no perfect day—just information you can use. | Kamu bisa mengubahnya kapan saja. Tidak ada hari yang harus sempurna—cukup informasi yang bisa kamu gunakan. | Supportive helper copy. |
| `onboardingDailyTargetTitle` | Set a daily target | Atur target harian | Optional target step. |
| `onboardingDailyTargetBody` | Use a target you already follow, or skip this for now. | Gunakan target yang sudah kamu ikuti, atau lewati untuk sekarang. | Do not prescribe a target. |
| `onboardingSkip` | Skip for now | Lewati untuk sekarang | Secondary action. |
| `onboardingReadyTitle` | You’re ready to log your first meal | Kamu siap mencatat makanan pertama | Final onboarding screen. |
| `onboardingReadyBody` | For the best estimate, use good light and keep the whole plate in frame. | Agar estimasi lebih baik, gunakan pencahayaan yang cukup dan pastikan seluruh piring terlihat. | Leads into capture guidance. |
| `onboardingStart` | Take my first photo | Ambil foto pertama | Primary CTA. |

## Camera and photo permissions

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `cameraPermissionTitle` | Allow camera access | Izinkan akses kamera | Pre-permission screen. |
| `cameraPermissionBody` | Camera access lets you photograph meals for analysis. We only analyze photos you choose to submit. | Akses kamera memungkinkan kamu memotret makanan untuk dianalisis. Kami hanya menganalisis foto yang kamu pilih untuk dikirim. | Must match implementation and privacy policy. |
| `cameraPermissionAction` | Allow camera | Izinkan kamera | Opens system prompt. |
| `cameraPermissionDeniedTitle` | Camera access is off | Akses kamera dinonaktifkan | Permission denied state. |
| `cameraPermissionDeniedBody` | Turn on camera access in Settings, or choose a photo from your gallery. | Aktifkan akses kamera di Pengaturan, atau pilih foto dari galeri. | Recovery guidance. |
| `cameraPermissionSettings` | Open Settings | Buka Pengaturan | Deep link to app settings. |
| `galleryPermissionTitle` | Choose a meal photo | Pilih foto makanan | Photo picker context; prefer Android system picker when available. |
| `galleryPermissionBody` | Select only the photo you want to analyze. | Pilih hanya foto yang ingin kamu analisis. | Avoid requesting broad photo-library access. |
| `notificationPermissionTitle` | Meal reminders | Pengingat makan | Optional permission. |
| `notificationPermissionBody` | Get a gentle reminder at times you choose. You can change this anytime. | Dapatkan pengingat ringan pada waktu yang kamu pilih. Kamu bisa mengubahnya kapan saja. | Do not pressure opt-in. |
| `notificationPermissionAction` | Allow reminders | Izinkan pengingat | Optional action. |
| `notificationPermissionNotNow` | Not now | Nanti saja | Secondary action. |

## Home and daily summary

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `homeGreetingMorning` | Good morning | Selamat pagi | Pair with optional display name separately. |
| `homeGreetingAfternoon` | Good afternoon | Selamat siang | Time-aware greeting. |
| `homeGreetingEvening` | Good evening | Selamat malam | Time-aware greeting. |
| `homeToday` | Today | Hari ini | Section title. |
| `homeSummaryCalories` | {consumed} of {target} kcal | {consumed} dari {target} kkal | Values localized by formatter. |
| `homeSummaryProtein` | {consumed} of {target} g protein | {consumed} dari {target} g protein | Do not concatenate unit fragments. |
| `homeNoTargetCalories` | {consumed} kcal logged | {consumed} kkal tercatat | No-target state. |
| `homeNoTargetProtein` | {consumed} g protein logged | {consumed} g protein tercatat | No-target state. |
| `homeScanCta` | Photograph a meal | Foto makanan | Primary home CTA. |
| `homeManualCta` | Add manually | Tambah manual | Secondary entry route. |
| `homeEmptyTitle` | Nothing logged yet | Belum ada yang dicatat | Empty diary card. |
| `homeEmptyBody` | Start with a photo or add a food manually. | Mulai dengan foto atau tambahkan makanan secara manual. | Neutral empty state. |
| `homeTargetReached` | You’ve reached today’s target | Target hari ini sudah tercapai | Positive, not moralizing. |
| `homeTargetOver` | {amount} over your target | {amount} di atas targetmu | Neutral factual wording; never use red “failure” language. |
| `homeStreak` | {count, plural, =1 {# day logged} other {# days logged}} | {count} hari mencatat | Do not imply that breaking a streak is failure. |

## Capture and real-time guidance

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `captureTitle` | Photograph your meal | Foto makananmu | Camera title. |
| `captureHintDefault` | Keep the whole meal inside the frame | Pastikan seluruh makanan berada di dalam bingkai | Persistent overlay hint. |
| `captureHintMoveCloser` | Move a little closer | Dekatkan kamera sedikit | Non-blocking guidance. |
| `captureHintMoveBack` | Move back to fit the whole plate | Mundurkan kamera agar seluruh piring terlihat | Non-blocking guidance. |
| `captureHintTooDark` | Add more light | Tambahkan pencahayaan | Avoid technical language. |
| `captureHintTooBright` | Reduce glare if possible | Kurangi pantulan cahaya jika memungkinkan | Non-blocking guidance. |
| `captureHintHoldSteady` | Hold still for a moment | Tahan kamera sejenak | Motion guidance. |
| `captureHintTopView` | A slight top-down angle works best | Sudut sedikit dari atas memberikan hasil terbaik | Guidance, not requirement. |
| `captureHintSeparateItems` | Make each food item visible if you can | Usahakan setiap jenis makanan terlihat | Helpful for mixed plates. |
| `captureHintReady` | Ready to capture | Siap difoto | Positive readiness state. |
| `captureAction` | Take photo | Ambil foto | Shutter accessibility label and CTA. |
| `captureGallery` | Choose from gallery | Pilih dari galeri | Alternative action. |
| `captureFlashOn` | Turn flash on | Nyalakan lampu kilat | Accessibility label. |
| `captureFlashOff` | Turn flash off | Matikan lampu kilat | Accessibility label. |
| `captureRetake` | Retake | Foto ulang | Review screen. |
| `captureUsePhoto` | Use this photo | Gunakan foto ini | Submit analysis. |
| `capturePrivacyNote` | Only submit photos you have permission to use. | Kirim hanya foto yang boleh kamu gunakan. | Short consent reminder. |

## Analysis and loading

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `analysisTitle` | Analyzing your meal | Menganalisis makananmu | Loading title. |
| `analysisStepFoods` | Identifying foods… | Mengenali jenis makanan… | Progress copy; ellipsis is intentional. |
| `analysisStepPortions` | Estimating portions… | Memperkirakan porsi… | Progress copy. |
| `analysisStepNutrition` | Calculating nutrition… | Menghitung informasi gizi… | Nutrition values should come from the food database after recognition. |
| `analysisWait` | This usually takes a few seconds. | Biasanya hanya perlu beberapa detik. | Do not promise an exact duration. |
| `analysisKeepOpen` | Keep the app open while we analyze your photo. | Biarkan aplikasi tetap terbuka saat kami menganalisis fotomu. | Use only if technically required. |
| `analysisCancel` | Cancel analysis | Batalkan analisis | Cancel action. |

## Result, confidence, and uncertainty

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `resultTitle` | Meal estimate | Estimasi makanan | Never “exact nutrition.” |
| `resultDetectedFoods` | Foods we found | Makanan yang terdeteksi | Section title. |
| `resultEstimatedTotal` | Estimated total | Estimasi total | Summary heading. |
| `resultCaloriesRange` | {low}–{high} kcal | {low}–{high} kkal | En dash; localized digits/grouping. |
| `resultProteinRange` | {low}–{high} g protein | {low}–{high} g protein | Range preferred when uncertainty is meaningful. |
| `resultConfidenceHigh` | High confidence | Keyakinan tinggi | Badge; pair with explanation. |
| `resultConfidenceMedium` | Medium confidence | Keyakinan sedang | Badge. |
| `resultConfidenceLow` | Low confidence—please review | Keyakinan rendah—mohon periksa | Always provide a correction route. |
| `resultConfidenceInfo` | Photo estimates can vary with portion size, ingredients, and cooking method. Review the items before saving. | Estimasi dari foto dapat berbeda tergantung ukuran porsi, bahan, dan cara memasak. Periksa setiap item sebelum menyimpan. | General uncertainty disclosure. |
| `resultNotExact` | This is an estimate, not a laboratory measurement. | Ini adalah estimasi, bukan hasil pengukuran laboratorium. | Detail sheet. |
| `resultRangeWhyTitle` | Why do I see a range? | Mengapa hasilnya berupa rentang? | Education sheet. |
| `resultRangeWhyBody` | A photo cannot show exact weight or every ingredient. The range reflects reasonable portion and recipe differences. | Foto tidak dapat menunjukkan berat yang tepat atau semua bahan. Rentang ini mencerminkan perbedaan porsi dan resep yang wajar. | Avoid claims of calibrated statistical probability unless validated. |
| `resultNeedsReviewTitle` | A quick check will improve this estimate | Periksa sebentar agar estimasi lebih baik | Follow-up intro. |
| `resultNeedsReviewBody` | Confirm the portions and any ingredients that may be hidden in the photo. | Konfirmasi porsi dan bahan yang mungkin tidak terlihat di foto. | Leads to questions. |
| `resultSaveMeal` | Save meal | Simpan makanan | Final action. |
| `resultSaved` | Meal saved | Makanan tersimpan | Confirmation toast. |
| `resultEditFirst` | Review items | Periksa item | Correction CTA. |
| `resultPhotoQualityLow` | We couldn’t see the meal clearly. Retake the photo or add items manually. | Makanan kurang terlihat jelas. Foto ulang atau tambahkan item secara manual. | Do not manufacture confident output. |

## Hidden ingredient follow-ups

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `followUpTitle` | A few quick details | Beberapa detail singkat | Sheet title. |
| `followUpSkip` | I’m not sure | Saya kurang yakin | Valid answer; do not force a guess. |
| `followUpOilQuestion` | Was extra oil used for cooking or added afterward? | Apakah ada minyak tambahan saat memasak atau setelah disajikan? | Hidden-oil question. |
| `followUpOilNone` | No extra oil | Tanpa minyak tambahan | Choice. |
| `followUpOilLittle` | A little (about 1 tsp) | Sedikit (sekitar 1 sdt) | Choice. |
| `followUpOilMedium` | Some (about 1 tbsp) | Cukup (sekitar 1 sdm) | Choice. |
| `followUpOilMore` | More than 1 tbsp | Lebih dari 1 sdm | Choice. |
| `followUpCoconutQuestion` | Does this dish contain coconut milk? | Apakah hidangan ini mengandung santan? | Santan question. |
| `followUpCoconutNone` | No coconut milk | Tanpa santan | Choice. |
| `followUpCoconutLight` | A little or diluted | Sedikit atau encer | Choice. |
| `followUpCoconutRich` | Rich or creamy | Kental atau gurih pekat | Choice; “creamy” alone is less natural. |
| `followUpSugarQuestion` | Was sugar or sweet sauce added? | Apakah ada tambahan gula atau saus manis? | Covers kecap manis and sauces. |
| `followUpSugarNone` | None | Tidak ada | Choice. |
| `followUpSugarLittle` | A little | Sedikit | Choice. |
| `followUpSugarMedium` | About 1 tbsp | Sekitar 1 sdm | Choice. |
| `followUpSugarMore` | More than 1 tbsp | Lebih dari 1 sdm | Choice. |
| `followUpSauceQuestion` | Which sauce or dressing was included? | Saus atau dressing apa yang digunakan? | Optional follow-up. |
| `followUpSaucePlaceholder` | Search or enter a sauce | Cari atau masukkan saus | Input placeholder. |
| `followUpFriedQuestion` | How was this cooked? | Bagaimana makanan ini dimasak? | Cooking method question. |
| `followUpMethodFried` | Fried | Digoreng | Choice. |
| `followUpMethodStirFried` | Stir-fried | Ditumis | Choice. |
| `followUpMethodGrilled` | Grilled | Dibakar | Choice. |
| `followUpMethodBoiled` | Boiled or steamed | Direbus atau dikukus | Choice. |
| `followUpUpdateEstimate` | Update estimate | Perbarui estimasi | Recalculate CTA. |
| `followUpChanged` | Estimate updated from your answers | Estimasi diperbarui berdasarkan jawabanmu | Confirmation. |

## Food and portion correction

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `editMealTitle` | Review meal | Periksa makanan | Editor title. |
| `editFoodName` | Food name | Nama makanan | Field label. |
| `editSearchFood` | Search foods | Cari makanan | Search placeholder. |
| `editSearchLocalHint` | Try “rendang,” “tempe,” or “nasi uduk” | Coba “rendang”, “tempe”, atau “nasi uduk” | Localized examples. |
| `editPortion` | Portion | Porsi | Field label. |
| `editQuantity` | Quantity | Jumlah | Field label. |
| `editUnit` | Unit | Satuan | Field label. |
| `editGrams` | grams | gram | Unit name. |
| `editPiece` | {count, plural, =1 {# piece} other {# pieces}} | {count} buah | Generic discrete item. |
| `editBowl` | {count, plural, =1 {# bowl} other {# bowls}} | {count} mangkuk | Portion unit. |
| `editPlate` | {count, plural, =1 {# plate} other {# plates}} | {count} piring | Portion unit. |
| `editTablespoon` | {count, plural, =1 {# tablespoon} other {# tablespoons}} | {count} sdm | Portion unit. |
| `editTeaspoon` | {count, plural, =1 {# teaspoon} other {# teaspoons}} | {count} sdt | Portion unit. |
| `editAddFood` | Add another food | Tambah makanan lain | Add row action. |
| `editRemoveFood` | Remove {foodName} | Hapus {foodName} | Accessibility label/dialog title. |
| `editRemoveConfirm` | Remove this item from the meal? | Hapus item ini dari makanan? | Confirmation body. |
| `editNutritionUpdated` | Nutrition updated | Informasi gizi diperbarui | Recalculation toast. |
| `editNoFoodFound` | No matching food found | Makanan tidak ditemukan | Search empty state. |
| `editCreateCustom` | Add as a custom food | Tambahkan sebagai makanan khusus | User-entered nutrition route. |
| `editCustomDisclaimer` | Nutrition for custom foods comes from the values you enter. | Informasi gizi makanan khusus berasal dari nilai yang kamu masukkan. | Clarifies source. |

## Diary and meal history

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `diaryTitle` | Food diary | Catatan makanan | Page title. |
| `diaryToday` | Today | Hari ini | Date shortcut. |
| `diaryYesterday` | Yesterday | Kemarin | Date shortcut. |
| `diaryDate` | {date} | {date} | Locale-formatted full/medium date. |
| `diaryBreakfast` | Breakfast | Sarapan | Meal group. |
| `diaryLunch` | Lunch | Makan siang | Meal group. |
| `diaryDinner` | Dinner | Makan malam | Meal group. |
| `diarySnack` | Snack | Camilan | Meal group. |
| `diaryMealTotal` | {calories} kcal · {protein} g protein | {calories} kkal · {protein} g protein | Summary line. |
| `diaryEmptyDayTitle` | No meals logged for this day | Belum ada makanan yang dicatat hari ini | Empty state. |
| `diaryEmptyDayBody` | Add a meal whenever it’s useful to you. | Tambahkan makanan kapan pun kamu membutuhkannya. | No guilt or streak pressure. |
| `diaryCopyMeal` | Copy to another day | Salin ke hari lain | Reuse action. |
| `diaryDeleteMealTitle` | Delete this meal? | Hapus makanan ini? | Confirmation title. |
| `diaryDeleteMealBody` | This removes the meal and its nutrition values from your diary. | Makanan beserta nilai gizinya akan dihapus dari catatan. | Consequence. |
| `diaryDeleteMealAction` | Delete meal | Hapus makanan | Destructive CTA. |
| `diaryMealDeleted` | Meal deleted | Makanan dihapus | Confirmation toast. |
| `diaryUndo` | Undo | Urungkan | Preferred recoverability. |

## Paywall, plans, and billing

All prices must come from Google Play `ProductDetails`; never embed currency symbols or converted prices in production copy. The recommended catalog is a monthly and annual product, with local base prices configured in Play Console (for example Rp49.000/month and Rp299.000/year in Indonesia, and a launch price around US$19.99/year where appropriate).

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `paywallTitle` | Make meal logging easier | Catat makanan dengan lebih mudah | Benefit-led, not fear-led. |
| `paywallBody` | Get more photo analyses, full history, and deeper nutrition insights. | Dapatkan lebih banyak analisis foto, riwayat lengkap, dan wawasan gizi yang lebih mendalam. | Only list shipped entitlements. |
| `paywallBenefitScans` | More meal photo analyses | Lebih banyak analisis foto makanan | Avoid “unlimited” unless truly unlimited. |
| `paywallBenefitHistory` | Full meal history | Riwayat makanan lengkap | Entitlement. |
| `paywallBenefitInsights` | Weekly calorie and protein insights | Wawasan kalori dan protein mingguan | Entitlement. |
| `paywallBenefitSupport` | Help improve Indonesian food coverage | Bantu mengembangkan cakupan makanan Indonesia | Optional mission benefit, not a promise of donation. |
| `paywallMonthlyName` | Monthly | Bulanan | Plan label. |
| `paywallMonthlyPrice` | {price} per month | {price} per bulan | `{price}` is store-formatted. |
| `paywallAnnualName` | Annual | Tahunan | Plan label. |
| `paywallAnnualPrice` | {price} per year | {price} per tahun | `{price}` is store-formatted. |
| `paywallAnnualEquivalent` | About {price} per month | Sekitar {price} per bulan | Calculated and locale-formatted; optional. |
| `paywallSavePercent` | Save {percent}% | Hemat {percent}% | Show only when mathematically valid. |
| `paywallIntroPrice` | Introductory price | Harga perkenalan | Show only when supplied by Google Play. |
| `paywallSubscribe` | Subscribe | Berlangganan | Primary CTA. |
| `paywallContinueFree` | Continue with free plan | Lanjut dengan paket gratis | Visible secondary CTA where applicable. |
| `paywallRestore` | Restore purchases | Pulihkan pembelian | Required account recovery route. |
| `paywallManage` | Manage subscription | Kelola langganan | Opens Google Play subscription management. |
| `paywallRecurringDisclosure` | Recurring billing. Cancel anytime in Google Play. | Tagihan berulang. Batalkan kapan saja melalui Google Play. | Place near CTA. |
| `paywallRenewalDisclosure` | Your subscription renews automatically unless canceled before the renewal date. | Langganan diperpanjang otomatis kecuali dibatalkan sebelum tanggal perpanjangan. | Confirm exact terms with Play Billing configuration. |
| `paywallChargeDisclosure` | Google Play will charge {price} for each {billingPeriod}. | Google Play akan menagih {price} setiap {billingPeriod}. | Use store-formatted values. |
| `paywallTerms` | Terms | Ketentuan | Link. |
| `paywallPrivacy` | Privacy Policy | Kebijakan Privasi | Link. |
| `purchasePending` | Purchase pending | Pembelian sedang diproses | Pending state. |
| `purchasePendingBody` | Google Play is processing your payment. Access will update when it’s complete. | Google Play sedang memproses pembayaranmu. Akses akan diperbarui setelah selesai. | Needed for pending transactions. |
| `purchaseSuccess` | You’re now on Pro | Kamu sekarang menggunakan Pro | Success title. |
| `purchaseSuccessBody` | Your Pro features are ready. | Fitur Pro sudah siap digunakan. | Success body. |
| `purchaseCanceled` | Purchase canceled | Pembelian dibatalkan | User-canceled state; no blame. |
| `purchaseFailed` | We couldn’t complete the purchase | Pembelian belum berhasil | Error title. |
| `purchaseFailedBody` | You weren’t charged. Check your connection or payment method, then try again. | Kamu tidak dikenai biaya. Periksa koneksi atau metode pembayaran, lalu coba lagi. | Only claim no charge if verified by billing result. Otherwise use generic copy. |
| `restoreSuccess` | Purchases restored | Pembelian berhasil dipulihkan | Confirmation. |
| `restoreNone` | No active purchase found for this Google Play account. | Tidak ada pembelian aktif pada akun Google Play ini. | Empty restore result. |
| `storeUnavailable` | Plans are temporarily unavailable | Paket untuk sementara tidak tersedia | Play product query failure. |

## General, network, and analysis errors

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `errorGenericTitle` | Something went wrong | Terjadi kendala | Calm generic error. |
| `errorGenericBody` | Try again in a moment. | Coba lagi beberapa saat lagi. | Generic recovery. |
| `errorOfflineTitle` | You’re offline | Kamu sedang offline | Network state. |
| `errorOfflineBody` | Connect to the internet to analyze a new photo. Saved meals remain available. | Hubungkan ke internet untuk menganalisis foto baru. Makanan yang tersimpan tetap tersedia. | Use only if saved meals are actually offline-capable. |
| `errorTimeoutTitle` | Analysis is taking longer than expected | Analisis memerlukan waktu lebih lama | Timeout title. |
| `errorTimeoutBody` | Try again with the same photo. | Coba lagi dengan foto yang sama. | Preserve photo locally when promised. |
| `errorUploadTitle` | Photo upload failed | Foto gagal dikirim | Upload failure. |
| `errorUploadBody` | Check your connection and try again. | Periksa koneksi lalu coba lagi. | Recovery. |
| `errorImageType` | Choose a JPG, PNG, or HEIC image. | Pilih gambar JPG, PNG, atau HEIC. | Match actual decoder support. |
| `errorImageTooLarge` | This photo is too large. Choose another photo or reduce its size. | Ukuran foto terlalu besar. Pilih foto lain atau perkecil ukurannya. | Size validation. |
| `errorNoFoodTitle` | We couldn’t find food in this photo | Kami tidak menemukan makanan di foto ini | Recognition failure. |
| `errorNoFoodBody` | Retake the photo with the meal clearly visible, or add foods manually. | Foto ulang dengan makanan terlihat jelas, atau tambahkan makanan secara manual. | Recovery options. |
| `errorServerTitle` | Service temporarily unavailable | Layanan untuk sementara tidak tersedia | 5xx state. |
| `errorServerBody` | Your photo wasn’t saved to your diary. Please try again later. | Foto belum disimpan ke catatanmu. Silakan coba lagi nanti. | Match data behavior. |
| `errorRateLimitTitle` | Analysis limit reached | Batas analisis tercapai | Free/paid quota. |
| `errorRateLimitFree` | You’ve used today’s free analyses. Add the meal manually or try again tomorrow. | Analisis gratis hari ini sudah digunakan. Tambahkan makanan secara manual atau coba lagi besok. | No pressure to subscribe. |
| `errorRateLimitPro` | We’re receiving a lot of requests. Try again shortly. | Permintaan sedang tinggi. Coba lagi sebentar lagi. | Paid throttling must not suggest plan limit unless true. |
| `errorSessionExpired` | Please sign in again | Silakan masuk kembali | Auth error title. |
| `errorSessionExpiredBody` | Your session ended to keep your account secure. | Sesimu berakhir untuk menjaga keamanan akun. | Auth explanation. |
| `errorRequiredField` | This field is required | Kolom ini wajib diisi | Validation. |
| `errorInvalidValue` | Enter a valid value | Masukkan nilai yang valid | Validation. |
| `errorPositiveNumber` | Enter a number greater than zero | Masukkan angka lebih dari nol | Portion validation. |

## Settings, privacy, and account deletion

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `settingsTitle` | Settings | Pengaturan | Page title. |
| `settingsLanguage` | Language | Bahasa | Setting row. |
| `settingsLanguageSystem` | Use device language | Ikuti bahasa perangkat | Locale option. |
| `settingsEnglish` | English | English | Language names should be self-identifying. |
| `settingsIndonesian` | Bahasa Indonesia | Bahasa Indonesia | Language names should be self-identifying. |
| `settingsUnits` | Units | Satuan | Setting row. |
| `settingsPrivacy` | Privacy | Privasi | Section title. |
| `privacyPolicy` | Privacy Policy | Kebijakan Privasi | Link. |
| `privacyPhotosTitle` | How meal photos are used | Cara foto makanan digunakan | Explanation title. |
| `privacyPhotosBody` | Photos you submit are used to analyze your meal. See the Privacy Policy for retention, service providers, and your choices. | Foto yang kamu kirim digunakan untuk menganalisis makananmu. Lihat Kebijakan Privasi untuk mengetahui masa penyimpanan, penyedia layanan, dan pilihanmu. | Do not invent retention promises here. |
| `privacyConsentAnalysis` | I agree to send this photo for meal analysis. | Saya setuju mengirim foto ini untuk analisis makanan. | Use only if affirmative consent is legally/product-required; avoid dark patterns. |
| `privacyExportData` | Download my data | Unduh data saya | Data portability action. |
| `privacyDeleteAccount` | Delete account | Hapus akun | Destructive settings row. |
| `deleteAccountTitle` | Delete your account? | Hapus akunmu? | First confirmation. |
| `deleteAccountBody` | This permanently deletes your account, meal history, saved photos, and personal settings after any stated retention period. This can’t be undone. | Tindakan ini akan menghapus akun, riwayat makanan, foto tersimpan, dan pengaturan pribadimu secara permanen setelah masa penyimpanan yang disebutkan. Tindakan ini tidak dapat dibatalkan. | Adapt to actual retention/legal obligations before release. |
| `deleteAccountSubscriptionWarning` | Deleting your account does not automatically cancel a Google Play subscription. Cancel it in Google Play to prevent future charges. | Menghapus akun tidak otomatis membatalkan langganan Google Play. Batalkan melalui Google Play agar tidak ada tagihan berikutnya. | Important billing disclosure. |
| `deleteAccountManageSubscription` | Manage subscription first | Kelola langganan terlebih dahulu | Opens Play. |
| `deleteAccountConfirmLabel` | Type DELETE to confirm | Ketik HAPUS untuk mengonfirmasi | If typed confirmation is used. Localize expected token. |
| `deleteAccountConfirmAction` | Permanently delete account | Hapus akun secara permanen | Final destructive CTA. |
| `deleteAccountProcessing` | Deleting your account… | Menghapus akunmu… | Progress state. |
| `deleteAccountSuccess` | Your account has been deleted | Akunmu telah dihapus | Completion. |
| `deleteAccountFailed` | We couldn’t delete your account | Akun belum berhasil dihapus | Error title. |
| `deleteAccountFailedBody` | Your account is still active. Try again or contact support. | Akunmu masih aktif. Coba lagi atau hubungi dukungan. | State must be accurate. |
| `signOut` | Sign out | Keluar | Account action. |

## Health and medical disclaimer

| Key | English | Bahasa Indonesia | Usage note |
|---|---|---|---|
| `healthDisclaimerShort` | Nutrition values are estimates and are for general wellness only. | Nilai gizi merupakan estimasi dan hanya untuk kebugaran umum. | Onboarding/settings short form. |
| `healthDisclaimerTitle` | Important nutrition information | Informasi gizi penting | Full disclaimer title. |
| `healthDisclaimerBody` | MyIdealBody AI provides estimated nutrition information for general wellness and education. It does not provide medical advice, diagnosis, or treatment. Do not use it to make urgent or clinical decisions. If you have a medical condition, are pregnant, have an eating disorder or a history of one, or need a therapeutic diet, consult a qualified healthcare professional. | MyIdealBody AI memberikan estimasi informasi gizi untuk kebugaran umum dan edukasi. Aplikasi ini tidak memberikan saran, diagnosis, atau perawatan medis. Jangan gunakan aplikasi ini untuk mengambil keputusan darurat atau klinis. Jika kamu memiliki kondisi medis, sedang hamil, memiliki gangguan makan atau riwayatnya, atau memerlukan diet terapeutik, konsultasikan dengan tenaga kesehatan yang kompeten. | Legal review required before launch. Avoid saying “doctor” only; users may need a dietitian. |
| `healthDisclaimerEmergency` | If you may be experiencing a medical emergency, contact local emergency services. | Jika kamu mungkin mengalami kondisi darurat medis, hubungi layanan darurat setempat. | Do not hardcode one country’s emergency number in global copy. |
| `healthDisclaimerAllergy` | A photo cannot reliably identify allergens or cross-contamination. Check ingredients with the food provider. | Foto tidak dapat mengenali alergen atau kontaminasi silang secara andal. Pastikan kandungannya kepada penyedia makanan. | Display where ingredient/allergen expectations could arise. |
| `healthDisclaimerAccept` | I understand | Saya mengerti | Acknowledgment, not waiver language. |
| `supportEatingConcern` | If tracking food feels distressing, consider pausing and speaking with someone you trust or a qualified professional. | Jika mencatat makanan terasa mengganggu, pertimbangkan untuk berhenti sejenak dan berbicara dengan orang yang kamu percaya atau tenaga profesional. | Optional wellbeing message; never infer a diagnosis. |

## Translation glossary

Use these terms consistently across UI, help content, notifications, and store listing.

| English source term | Preferred Bahasa Indonesia | Avoid / note |
|---|---|---|
| analyze / analysis | analisis / menganalisis | Avoid *scan* when the system performs image analysis. |
| calorie(s) | kalori | Unit is `kkal` in Indonesian UI, although `kcal` may remain in food data. |
| carbohydrate / carbs | karbohidrat | Avoid shortening to *karbo* in formal UI. |
| coconut milk | santan | Do not translate literally as *susu kelapa* for Indonesian dishes. |
| confidence | keyakinan | Refers to model confidence, not user confidence; explain in context. |
| diary / food diary | catatan / catatan makanan | Avoid *diari makanan*. |
| estimate (noun) | estimasi | Always distinguish from a measured result. |
| estimate (verb) | memperkirakan | Prefer natural verb form in sentences. |
| fat | lemak | — |
| fiber | serat | — |
| food database | basis data makanan | “Database makanan” is acceptable in technical/support copy. |
| gallery | galeri | — |
| insights | wawasan | — |
| meal | makanan | Use *waktu makan* only when referring to breakfast/lunch/dinner grouping. |
| nutrition | gizi / informasi gizi | Avoid *nutrisi* where *gizi* sounds more natural; “nutrition tracker” can be *pencatat gizi*. |
| portion | porsi | — |
| protein | protein | — |
| serving | porsi | Context may require *takaran saji* for packaged-food labels. |
| subscription | langganan | Verb: *berlangganan*. |
| target / goal | target / tujuan | Use *target* for numeric daily values and *tujuan* for intent. |
| tablespoon | sendok makan (`sdm`) | Keep abbreviation lowercase. |
| teaspoon | sendok teh (`sdt`) | Keep abbreviation lowercase. |
| whole plate | seluruh piring | Means all food in frame, not a “full plate.” |

## Future-localization guidelines

### Message structure

1. Use stable semantic keys, not English sentences as keys.
2. Keep complete thoughts in one message. Do not build sentences by concatenating fragments, because word order changes across languages.
3. Use ICU named placeholders: `{foodName}`, `{count}`, `{price}`, `{date}`. Names must describe meaning, not layout (`{amount}`, not `{text2}`).
4. Add translator descriptions for every placeholder, especially whether a value already includes a unit or currency symbol.
5. Never interpolate untrusted model output into a message without escaping it for the target UI surface.

### Plurals and grammar

1. Use ICU plural/select rules even when the first two locales render identically. Future languages may require several forms.
2. Keep number and noun together inside the plural branch in English. Do not append `s` in code.
3. Indonesian generally does not need plural inflection after a number; prefer `{count} hari`, not repeated nouns such as *hari-hari*.
4. Provide gender-neutral sentences and avoid pronoun-dependent grammar where possible.

### Numbers, currency, dates, and units

1. Format with the active locale: English commonly shows `1,250.5`; Indonesian shows `1.250,5`.
2. Get subscription display prices and billing periods from Google Play. Never manually convert USD to IDR and never hardcode `$` or `Rp` next to a backend number.
3. Keep nutrient numbers separate from billing currency formatters. Nutrition values may use fewer decimal places than weights.
4. Use locale-aware dates and times. Store timestamps in UTC; render them in the user’s time zone.
5. Treat units as translatable messages. Allow metric/imperial preferences where relevant, but keep source nutrition calculations in a single canonical unit.
6. Use a non-breaking space between a number and short unit when the UI framework supports it.

### Tone and safety

1. Avoid guilt, punishment, fear, body-shaming, or moral labels. Say “above your target,” never “failed,” “bad,” or “cheated.”
2. Do not congratulate users for eating less, skipping meals, or maintaining extreme deficits.
3. Do not claim a meal photo reveals exact weight, ingredients, allergens, or clinical nutrition values.
4. Preserve uncertainty words in every language. Translators must not turn “may,” “estimate,” or a range into a definitive result.
5. Medical, privacy, billing, and deletion language must receive in-market legal/policy review before release.
6. Keep subscription decline paths visible and neutral. Do not use urgency unless a genuine, store-configured offer has an end date.

### Layout and accessibility

1. Design for at least 30–50% text expansion and test 200% system font scaling.
2. Do not put essential text inside images. Icons need localized accessibility labels.
3. Avoid all caps; screen readers may spell it out, and casing rules differ.
4. Support right-to-left mirroring before adding Arabic, Persian, Hebrew, or Urdu. Do not bake directional arrows into assets.
5. Keep camera guidance short enough to read while framing a photo, but expose the same instruction to assistive technology.
6. Use sentence case unless a platform convention requires otherwise.

### Food names and model output

1. Store a canonical food ID separately from localized display names and synonyms.
2. Let users search both local and common alternate names, such as *sweet soy sauce* and *kecap manis*.
3. Do not machine-translate protected dish names by default: keep *rendang*, *gado-gado*, *tempe*, and *nasi uduk*, then add a short explanation where needed.
4. Localize model-generated explanations through structured templates. Avoid asking the vision model to produce final UI prose in every language.
5. Record user corrections by canonical food ID so learning signals are not fragmented by language.

### Notification examples

| Key | English | Bahasa Indonesia |
|---|---|---|
| `reminderMealTitle` | Ready to log a meal? | Siap mencatat makanan? |
| `reminderMealBody` | A quick photo can give you a useful estimate. | Foto singkat bisa memberikan estimasi yang berguna. |
| `weeklyInsightTitle` | Your weekly summary is ready | Ringkasan mingguanmu sudah siap |
| `weeklyInsightBody` | See your calorie and protein patterns. | Lihat pola kalori dan proteinmu. |

Notifications must be opt-in, easy to disable, and free from streak loss or guilt messaging.
