(() => {
  "use strict";

  document.documentElement.classList.add("js");

  const copyElements = [...document.querySelectorAll("[data-i18n]")];
  const ariaElements = [...document.querySelectorAll("[data-i18n-aria]")];
  const english = Object.fromEntries(copyElements.map((element) => [element.dataset.i18n, element.textContent.trim()]));
  Object.assign(english, {
    demoLoadingTwo: "Applying the selected portion…",
    demoLoadingThree: "Calculating a reference range…",
    apiButton: "Analyze photo",
    apiDemoBody: "Choose or capture a food photo. It is sent only after you press Analyze, and the result must be reviewed before use.",
    apiIdleKicker: "Photo analysis ready",
    apiIdleTitle: "Start with a clear meal photo",
    apiIdleBody: "Keep the whole plate visible and use good lighting. Press Analyze only when you are ready to send the selected photo.",
    apiModeTitle: "Photo analysis service configured",
    apiModeBody: "Your photo will be sent securely only after you press Analyze. Results remain estimates and must be reviewed.",
    apiLoadingKicker: "Photo analysis",
    apiLoadingOne: "Uploading your photo securely…",
    apiLoadingTwo: "Identifying possible foods…",
    apiLoadingThree: "Calculating nutrition ranges…",
    apiLoadingBody: "The configured service is processing the selected photo. This can take a few seconds.",
    apiResultKicker: "Photo estimate",
    apiFoodList: "Possible foods",
    apiNoteTitle: "Review this estimate",
    apiNoteBody: "A photo cannot reveal exact weight or hidden ingredients. Correct anything that looks wrong.",
    apiDisclaimer: "Photo-based estimate for general wellness—not a measurement or medical advice.",
    mockResultKicker: "Backend demo result",
    mockFoodList: "Fixed sample foods",
    mockConfidence: "Fixed demonstration",
    mockNoteTitle: "This service did not inspect your photo",
    mockNoteBody: "The configured backend is using its fixed mock provider. Treat these numbers as a product demonstration only.",
    mockDisclaimer: "Fixed backend demonstration—not image recognition, a measurement, or medical advice.",
    guidedConfidence: "Selection-based",
    guidedResultKicker: "Guided estimate",
    guidedListTitle: "Your inputs",
    guidedNoteTitle: "Photo recognition is not active",
    guidedNoteBody: "The photo stayed in your browser; these numbers come from the selections you made.",
    guidedDisclaimer: "Guided reference only—not image recognition, a measurement, or medical advice.",
    fileReady: "Photo ready",
    fileLocal: "kept in this browser",
    fileWillUpload: "sent only when you press Analyze",
    fileUploaded: "submitted to the configured photo service",
    fileMockUploaded: "sent to a demo backend that did not inspect it",
    fileRequestAttempted: "an upload was attempted; the request did not complete",
    fileTooLarge: "That image is larger than 10 MB. Choose a smaller file.",
    fileInvalid: "Choose a JPG, PNG, or WebP image.",
    fileEmpty: "That image file is empty. Choose another photo.",
    uploadFirst: "Add a photo to enable the estimate.",
    readyGuided: "Photo ready. Choose the closest meal and portion, then create the estimate.",
    readyApi: "Photo ready. Press Analyze to send it to the configured service.",
    apiFailed: "The photo service could not complete the request. You can use the guided estimate below instead.",
    genericApiError: "Photo analysis failed. Please try another photo.",
    yes: "Yes",
    no: "No",
    estimatedPortion: "Estimated portion",
    unavailable: "Unavailable",
  });
  const englishAria = Object.fromEntries(ariaElements.map((element) => [element.dataset.i18nAria, element.getAttribute("aria-label")]));
  englishAria.menuClose = "Close menu";

  const indonesian = {
    skipLink: "Lewati ke konten utama",
    navWhy: "Mengapa berbeda",
    navDemo: "Demo",
    navPricing: "Harga",
    navStatus: "Status produk",
    heroEyebrow: "Prototipe pengembangan · English + Bahasa Indonesia",
    heroTitle: "Titik awal yang lebih jelas untuk setiap piring.",
    heroBody: "Foto makanan untuk memperkirakan rentang kalori dan protein, periksa makanan yang terdeteksi, lalu sesuaikan hasilnya sebelum disimpan.",
    heroPrimary: "Coba demo interaktif",
    heroSecondary: "Lihat yang sudah tersedia",
    heroNote: "MVP berbasis kode untuk pengembangan beta tertutup—belum tersedia di Google Play.",
    trustRanges: "Rentang yang jujur",
    trustEditable: "Periksa sebelum menyimpan",
    trustLocal: "Fokus makanan Indonesia",
    phoneToday: "Hari ini",
    phoneGreeting: "Selamat siang",
    phoneLogged: "Tercatat",
    phoneProtein: "Protein",
    phoneMeals: "Makanan",
    phoneEntries: "3 catatan",
    phoneLunch: "Makan siang",
    phoneSnack: "Camilan",
    phoneCta: "Foto makanan",
    floatingProtein: "estimasi protein",
    floatingReview: "Periksa dahulu",
    floatingControl: "Kamu tetap memegang kendali",
    whyKicker: "Berguna, tanpa kepastian palsu",
    whyTitle: "Pencatatan gizi yang memahami keterbatasan sebuah foto.",
    whyBody: "Ukuran porsi, minyak, saus, dan bahan tersembunyi dapat mengubah angka. MyIdealBody AI menunjukkan ketidakpastian dan memudahkan pemeriksaan.",
    featureOneTitle: "Foto dengan panduan",
    featureOneBody: "Petunjuk pencahayaan dan bingkai sederhana membantu kamu mengambil foto diam yang berguna tanpa analisis video terus-menerus.",
    featureTwoTitle: "Lihat rentang yang wajar",
    featureTwoBody: "Kalori dan protein ditampilkan sebagai estimasi dengan tingkat keyakinan—bukan angka desimal yang seolah-olah pasti.",
    featureThreeTitle: "Periksa sebelum menyimpan",
    featureThreeBody: "Sesuaikan porsi yang terdeteksi dan periksa catatan tentang minyak, santan, atau saus manis. Penghitungan ulang dari jawaban masih direncanakan.",
    demoKicker: "Coba dengan makananmu",
    demoTitle: "Unggah foto makanan dan buat estimasi terpandu.",
    demoBody: "Foto tetap berada di browser ini. Sebelum layanan visi produksi terhubung, demo transparan ini menghitung rentang gizi dari jenis makanan dan porsi yang kamu pilih.",
    demoCamera: "Pratinjau foto",
    demoHint: "JPG, PNG, atau WebP · maksimal 10 MB",
    uploadPromptTitle: "Tambahkan foto makanan",
    uploadPromptBody: "Ketuk untuk memilih foto, atau seret dan lepaskan di sini",
    uploadButton: "Pilih foto",
    cameraButton: "Gunakan kamera",
    removePhoto: "Hapus",
    uploadPrivacy: "Belum ada foto · berkas tidak diunggah dalam mode demo ini.",
    demoButton: "Buat estimasi terpandu",
    demoIdleKicker: "Mode demo terpandu",
    demoIdleTitle: "Beri tahu apa yang ada di piring",
    demoIdleBody: "Pilih makanan dan porsi yang paling mendekati. Estimasi tetap berguna tanpa mengklaim bahwa situs sudah dapat mengenali foto secara visual.",
    demoTruthTitle: "Apa yang terjadi pada foto?",
    demoTruthBody: "Foto hanya ditampilkan di perangkatmu. Angka berasal dari pilihanmu, bukan pengenalan gambar.",
    mealLabel: "Makanan terdekat",
    mealPlate: "Nasi, ayam bakar, tempe, dan sayuran",
    mealFriedRice: "Nasi goreng dengan telur",
    mealGadoGado: "Gado-gado",
    mealSotoAyam: "Soto ayam dengan nasi",
    mealOther: "Lainnya / makanan campur",
    portionLabel: "Ukuran porsi",
    portionSmall: "Kecil",
    portionMedium: "Sedang",
    portionLarge: "Besar",
    extraOilTitle: "Tambahan minyak atau saus manis",
    extraOilBody: "Menambahkan perkiraan kalori tersembunyi",
    uploadFirst: "Tambahkan foto untuk mengaktifkan estimasi.",
    demoLoadingKicker: "Perhitungan terpandu",
    demoLoadingOne: "Menyiapkan estimasi…",
    demoLoadingTwo: "Menerapkan porsi yang dipilih…",
    demoLoadingThree: "Menghitung rentang referensi…",
    demoLoadingBody: "Pilihan makanan, porsi, dan minyak tambahan sedang diterapkan pada rentang referensi.",
    demoResultKicker: "Estimasi terpandu",
    demoConfidence: "Berdasarkan pilihan",
    demoCalories: "Kalori",
    demoProtein: "Protein",
    demoRangeNote: "Rentang mencerminkan kemungkinan perbedaan porsi dan resep.",
    demoInputs: "Pilihanmu",
    demoEditable: "Dapat disesuaikan",
    mealInput: "Makanan",
    portionInput: "Porsi",
    oilInput: "Tambahan minyak / saus",
    demoQuestionTitle: "Pengenalan foto belum aktif",
    demoQuestionBody: "Hubungkan API visi produksi sebelum menganggap gambar telah dianalisis.",
    adjustEstimate: "Sesuaikan pilihan",
    demoDisclaimer: "Hanya referensi terpandu—bukan pengenalan gambar, pengukuran, atau saran medis.",
    apiButton: "Analisis foto",
    apiDemoBody: "Pilih atau ambil foto makanan. Foto dikirim hanya setelah kamu menekan Analisis, dan hasilnya harus diperiksa sebelum digunakan.",
    apiIdleKicker: "Analisis foto siap",
    apiIdleTitle: "Mulai dengan foto makanan yang jelas",
    apiIdleBody: "Pastikan seluruh piring terlihat dan pencahayaan cukup. Tekan Analisis hanya saat kamu siap mengirim foto yang dipilih.",
    apiModeTitle: "Layanan analisis foto telah dikonfigurasi",
    apiModeBody: "Foto dikirim dengan aman hanya setelah kamu menekan Analisis. Hasil tetap berupa estimasi dan harus diperiksa.",
    apiLoadingKicker: "Analisis foto",
    apiLoadingOne: "Mengunggah foto dengan aman…",
    apiLoadingTwo: "Mengenali kemungkinan makanan…",
    apiLoadingThree: "Menghitung rentang gizi…",
    apiLoadingBody: "Layanan yang dikonfigurasi sedang memproses foto. Proses ini dapat memerlukan beberapa detik.",
    apiResultKicker: "Estimasi foto",
    apiFoodList: "Kemungkinan makanan",
    apiNoteTitle: "Periksa estimasi ini",
    apiNoteBody: "Foto tidak dapat menunjukkan berat pasti atau semua bahan tersembunyi. Koreksi hasil yang terlihat tidak tepat.",
    apiDisclaimer: "Estimasi berbasis foto untuk kebugaran umum—bukan pengukuran atau saran medis.",
    mockResultKicker: "Hasil demo backend",
    mockFoodList: "Makanan contoh tetap",
    mockConfidence: "Demonstrasi tetap",
    mockNoteTitle: "Layanan ini tidak memeriksa fotomu",
    mockNoteBody: "Backend yang dikonfigurasi masih memakai penyedia mock tetap. Anggap angka ini hanya sebagai demonstrasi produk.",
    mockDisclaimer: "Demonstrasi backend tetap—bukan pengenalan gambar, pengukuran, atau saran medis.",
    guidedConfidence: "Berdasarkan pilihan",
    guidedResultKicker: "Estimasi terpandu",
    guidedListTitle: "Pilihanmu",
    guidedNoteTitle: "Pengenalan foto belum aktif",
    guidedNoteBody: "Foto tetap berada di browser; angka ini berasal dari pilihan yang kamu buat.",
    guidedDisclaimer: "Hanya referensi terpandu—bukan pengenalan gambar, pengukuran, atau saran medis.",
    fileReady: "Foto siap",
    fileLocal: "tetap di browser ini",
    fileWillUpload: "dikirim hanya saat kamu menekan Analisis",
    fileUploaded: "dikirim ke layanan foto yang dikonfigurasi",
    fileMockUploaded: "dikirim ke backend demo yang tidak memeriksanya",
    fileRequestAttempted: "unggahan telah dicoba; permintaan tidak selesai",
    fileTooLarge: "Ukuran gambar lebih dari 10 MB. Pilih berkas yang lebih kecil.",
    fileInvalid: "Pilih gambar JPG, PNG, atau WebP.",
    fileEmpty: "Berkas gambar kosong. Pilih foto lain.",
    readyGuided: "Foto siap. Pilih makanan dan porsi terdekat, lalu buat estimasi.",
    readyApi: "Foto siap. Tekan Analisis untuk mengirimkannya ke layanan yang dikonfigurasi.",
    apiFailed: "Layanan foto tidak dapat menyelesaikan permintaan. Kamu dapat memakai estimasi terpandu di bawah.",
    genericApiError: "Analisis foto gagal. Coba foto lain.",
    yes: "Ya",
    no: "Tidak",
    estimatedPortion: "Estimasi porsi",
    unavailable: "Tidak tersedia",
    localKicker: "Berawal dari kebutuhan Indonesia",
    localTitle: "“Nasi campur” belum cukup jelas.",
    localBody: "Makanan sehari-hari dapat menggabungkan nasi, lauk, sayur, sambal, santan, dan minyak. Produk ini dirancang untuk mengajukan pertanyaan yang berguna dan memahami kekurangan label makanan yang terlalu umum.",
    compareTitle: "Alur pemeriksaan yang lebih baik",
    compareGeneric: "Tebakan umum",
    compareGenericBody: "“Nasi campur — 650 kkal”",
    compareProduct: "Pendekatan MyIdealBody",
    compareProductBody: "Kemungkinan komponen + rentang porsi + catatan tentang minyak atau santan + porsi yang dapat disesuaikan",
    howKicker: "Satu menit, tiga langkah",
    howTitle: "Dari piring ke catatan—tanpa terasa seperti mengisi spreadsheet.",
    stepOneTitle: "Foto",
    stepOneBody: "Gunakan panduan kamera atau pilih foto makanan dari galeri.",
    stepTwoTitle: "Periksa",
    stepTwoBody: "Periksa makanan yang terdeteksi, porsi, tingkat keyakinan, dan catatan tentang bahan tersembunyi.",
    stepThreeTitle: "Simpan",
    stepThreeBody: "Sesuaikan porsi yang kurang tepat, lalu tambahkan makanan ke catatan lokalmu.",
    privacyKicker: "Privasi harus terlihat jelas",
    privacyTitle: "Foto makananmu adalah data. Perlakukan dengan tepat.",
    privacyBody: "MVP dirancang dengan pengiriman foto yang disengaja, izin minimal, dan kontrol penghapusan yang jelas. Foto makanan tidak boleh digunakan untuk melatih model tanpa persetujuan terpisah.",
    privacyOneTitle: "Pilih yang ingin dikirim",
    privacyOneBody: "Tidak ada analisis kamera terus-menerus di versi pertama.",
    privacyTwoTitle: "Minta akses seperlunya",
    privacyTwoBody: "Gunakan pemilih foto sistem, bukan izin luas ke seluruh galeri.",
    privacyThreeTitle: "Jaga klaim kesehatan tetap jujur",
    privacyThreeBody: "Estimasi untuk kebugaran umum—bukan diagnosis atau saran medis.",
    pricingKicker: "Rencana harga peluncuran",
    pricingTitle: "Mulai gratis. Upgrade saat kebiasaanmu terbentuk.",
    pricingBody: "Ini adalah target harga peluncuran, bukan pembelian aktif di situs. Pembayaran akhir dan harga lokal akan ditangani oleh Google Play.",
    priceIndonesia: "Indonesia",
    priceLocalPlan: "Pro bulanan",
    perMonth: "/ bulan",
    priceLocalBody: "Pilihan bulanan yang terjangkau untuk pasar lokal pertama.",
    priceFeatureOne: "Lebih banyak analisis foto",
    priceFeatureTwo: "Rentang kalori dan protein yang dapat diperiksa",
    priceFeatureThree: "Rencana riwayat lebih panjang dan wawasan",
    priceCta: "Ikuti perkembangan beta",
    priceValue: "Nilai tahunan",
    priceGlobal: "Global",
    priceGlobalPlan: "Pro tahunan",
    perYear: "/ tahun",
    priceGlobalBody: "Sekitar US$20 per tahun untuk pasar peluncuran internasional.",
    pricingNote: "Target gratis: 3 analisis selesai per hari. Pajak, kurs, dan harga lokal Google Play dapat berbeda.",
    statusKicker: "Status produk yang transparan",
    statusTitle: "Kode MVP sudah siap. Rilis publik berbayar belum siap.",
    statusBody: "Klien Android dwibahasa, API, pengenal demo, alur pemeriksaan hasil, catatan lokal, dan antarmuka pembayaran tersedia di repositori. Validasi pengenalan produksi, autentikasi, pemeriksaan hak akses di server, dan pengaturan Play Console masih diperlukan sebelum peluncuran.",
    readyLabel: "Siap dalam kode",
    readyBody: "MVP Inggris + Indonesia dan backend terdokumentasi",
    nextLabel: "Tahap berikutnya",
    nextBody: "Beta tertutup terukur dengan makanan Indonesia yang representatif",
    laterLabel: "Belum aktif",
    laterBody: "Langganan Google Play dan analisis makanan produksi",
    statusCta: "Lihat kode dan rilis",
    faqKicker: "Pertanyaan bagus, jawaban langsung",
    faqTitle: "Sebelum mengarahkan kamera.",
    faqOneQ: "Apakah foto dapat mengukur kalori secara tepat?",
    faqOneA: "Tidak. Foto tidak dapat menunjukkan berat yang tepat atau setiap bahan. MyIdealBody AI dirancang untuk memberikan rentang yang berguna, menjelaskan ketidakpastian, dan memungkinkan kamu memeriksa hasil.",
    faqTwoQ: "Apakah aplikasi sudah tersedia di Google Play?",
    faqTwoA: "Belum. Repositori ini adalah MVP pengembangan untuk persiapan beta tertutup. Rilis publik berbayar perlu validasi produksi dan pengaturan Play terlebih dahulu.",
    faqThreeQ: "Apakah aplikasi menganalisis video langsung?",
    faqThreeA: "Tidak. Situs ini menggunakan satu foto diam. Jika API produksi belum dikonfigurasi, foto tetap di browser dan estimasi berasal dari pilihanmu—bukan pengenalan visual.",
    faqFourQ: "Apakah ini saran medis atau dietetik?",
    faqFourA: "Bukan. Produk hanya memberi estimasi untuk kebugaran umum dan bukan diagnosis, perawatan, pengukuran laboratorium, atau pengganti tenaga profesional.",
    footerTagline: "Titik awal yang praktis dan jujur untuk pencatatan gizi sehari-hari.",
    footerPrivacy: "Privasi",
    footerSource: "Kode sumber",
    footerDisclaimer: "Estimasi untuk kebugaran umum. Bukan saran medis.",
  };

  const indonesianAria = {
    brandHome: "Beranda MyIdealBody AI",
    menuOpen: "Buka menu",
    menuClose: "Tutup menu",
    primaryNav: "Navigasi utama",
    languagePicker: "Pilih bahasa",
    productPrinciples: "Prinsip produk",
    phonePreview: "Pratinjau aplikasi MyIdealBody AI",
    uploadStage: "Pilih foto makanan",
    mealExamples: "Contoh makanan Indonesia",
  };

  const metaDescription = document.querySelector("#meta-description");
  const languageButtons = [...document.querySelectorAll("[data-lang]")];
  let language = "en";
  let demoState = "idle";
  let demoTimers = [];

  const getCopy = (key) => (language === "id" ? indonesian[key] : english[key]);
  const getAriaCopy = (key) => (language === "id" ? indonesianAria[key] : englishAria[key]);

  function setLanguage(nextLanguage, persist = true) {
    language = nextLanguage === "id" ? "id" : "en";
    document.documentElement.lang = language;
    copyElements.forEach((element) => {
      const value = getCopy(element.dataset.i18n);
      if (value) element.textContent = value;
    });
    ariaElements.forEach((element) => {
      const key = element === menuButton && element.getAttribute("aria-expanded") === "true" ? "menuClose" : element.dataset.i18nAria;
      const value = getAriaCopy(key);
      if (value) element.setAttribute("aria-label", value);
    });
    languageButtons.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.lang === language));
    });
    document.title = language === "id"
      ? "MyIdealBody AI — Estimasi gizi dari foto"
      : "MyIdealBody AI — Photo nutrition estimates";
    metaDescription.content = language === "id"
      ? "MyIdealBody AI membantu memperkirakan rentang kalori dan protein dari foto makanan, dengan hasil yang dapat diperiksa untuk makanan sehari-hari di Indonesia."
      : "MyIdealBody AI helps you estimate calorie and protein ranges from a meal photo, with reviewable results designed for everyday Indonesian food.";
    renderDynamicDemoCopy();
    if (persist) {
      try { localStorage.setItem("myidealbody-language", language); } catch (_) { /* Storage is optional. */ }
    }
  }

  languageButtons.forEach((button) => {
    button.addEventListener("click", () => setLanguage(button.dataset.lang));
  });

  let savedLanguage = null;
  try { savedLanguage = localStorage.getItem("myidealbody-language"); } catch (_) { /* Storage is optional. */ }
  const initialLanguage = savedLanguage || (navigator.language.toLowerCase().startsWith("id") ? "id" : "en");

  const menuButton = document.querySelector("[data-menu-button]");
  const navPanel = document.querySelector("[data-nav-panel]");
  const header = document.querySelector("[data-header]");

  function closeMenu() {
    menuButton.setAttribute("aria-expanded", "false");
    menuButton.setAttribute("aria-label", getAriaCopy("menuOpen"));
    navPanel.classList.remove("is-open");
    header.classList.remove("is-open");
    document.body.classList.remove("nav-open");
  }

  menuButton.addEventListener("click", () => {
    const shouldOpen = menuButton.getAttribute("aria-expanded") !== "true";
    menuButton.setAttribute("aria-expanded", String(shouldOpen));
    menuButton.setAttribute("aria-label", getAriaCopy(shouldOpen ? "menuClose" : "menuOpen"));
    navPanel.classList.toggle("is-open", shouldOpen);
    header.classList.toggle("is-open", shouldOpen);
    document.body.classList.toggle("nav-open", shouldOpen);
  });

  navPanel.querySelectorAll("a").forEach((link) => link.addEventListener("click", closeMenu));
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeMenu();
  });
  window.addEventListener("resize", () => {
    if (window.innerWidth > 880) closeMenu();
  });

  const updateHeader = () => header.classList.toggle("is-scrolled", window.scrollY > 18);
  updateHeader();
  window.addEventListener("scroll", updateHeader, { passive: true });

  const demoShell = document.querySelector("[data-demo-shell]");
  const demoBodyElement = document.querySelector("[data-i18n='demoBody']");
  const demoButton = document.querySelector("[data-demo-button]");
  const demoButtonText = demoButton.querySelector("[data-i18n]");
  const demoResult = document.querySelector("[data-demo-result]");
  const idlePanel = document.querySelector("[data-result-idle]");
  const loadingPanel = document.querySelector("[data-result-loading]");
  const resultPanel = document.querySelector("[data-result-content]");
  const loadingTitle = document.querySelector("[data-demo-loading-title]");
  const loadingKicker = loadingPanel.querySelector(".section-kicker");
  const loadingBody = document.querySelector("[data-loading-body]");
  const analysisForm = document.querySelector("[data-analysis-form]");
  const uploadStage = document.querySelector("[data-upload-stage]");
  const photoInput = document.querySelector("[data-photo-input]");
  const cameraInput = document.querySelector("[data-camera-input]");
  const photoPreview = document.querySelector("[data-photo-preview]");
  const removePhotoButton = document.querySelector("[data-remove-photo]");
  const fileStatus = document.querySelector("[data-file-status]");
  const formHelp = document.querySelector("[data-form-help]");
  const modeNote = document.querySelector("[data-mode-note]");
  const modeTitle = document.querySelector("[data-mode-title]");
  const modeBody = document.querySelector("[data-mode-body]");
  const guidedFields = [...document.querySelectorAll("[data-guided-field]")];
  const mealSelect = document.querySelector("[data-meal-select]");
  const portionSelect = document.querySelector("[data-portion-select]");
  const extraOil = document.querySelector("[data-extra-oil]");
  const adjustEstimateButton = document.querySelector("[data-adjust-estimate]");
  const resultKicker = document.querySelector("[data-result-kicker]");
  const resultTitle = document.querySelector("[data-result-title]");
  const resultConfidence = document.querySelector("[data-result-confidence]");
  const calorieResult = document.querySelector("[data-calorie-result]");
  const proteinResult = document.querySelector("[data-protein-result]");
  const resultListTitle = document.querySelector("[data-result-list-title]");
  const resultRows = [...document.querySelectorAll("[data-result-row]")];
  const resultNoteTitle = document.querySelector("[data-result-note-title]");
  const resultNoteBody = document.querySelector("[data-result-note-body]");
  const resultDisclaimer = document.querySelector("[data-result-disclaimer]");
  const idleKicker = idlePanel.querySelector(".section-kicker");
  const idleTitle = idlePanel.querySelector("h3");
  const idleBody = idlePanel.querySelector(":scope > p:not(.section-kicker)");

  const MAX_IMAGE_BYTES = 10 * 1024 * 1024;
  const ALLOWED_IMAGE_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);
  const GUIDED_PRESETS = {
    plate: { calories: [610, 760], protein: [38, 49], titleKey: "mealPlate" },
    friedRice: { calories: [520, 680], protein: [15, 24], titleKey: "mealFriedRice" },
    gadoGado: { calories: [430, 590], protein: [16, 25], titleKey: "mealGadoGado" },
    sotoAyam: { calories: [360, 520], protein: [23, 35], titleKey: "mealSotoAyam" },
    other: { calories: [350, 800], protein: [10, 42], titleKey: "mealOther" },
  };
  const PORTION_MULTIPLIERS = { small: 0.75, medium: 1, large: 1.35 };
  const PORTION_KEYS = { small: "portionSmall", medium: "portionMedium", large: "portionLarge" };

  let currentFile = null;
  let currentSource = "gallery";
  let previewUrl = null;
  let uploadErrorKey = null;
  let lastResult = null;
  let activeRequest = null;
  let requestSequence = 0;
  let uploadOutcome = null;

  function normalizeApiBaseUrl(rawValue) {
    if (!rawValue || !rawValue.trim()) return null;
    try {
      const url = new URL(rawValue.trim());
      const isLoopback = ["localhost", "127.0.0.1", "::1"].includes(url.hostname);
      if (url.protocol !== "https:" && !(url.protocol === "http:" && isLoopback)) return null;
      if (url.username || url.password || url.search || url.hash) return null;
      return url.toString().replace(/\/+$/, "");
    } catch (_) {
      return null;
    }
  }

  const configuredApiBaseUrl = normalizeApiBaseUrl(document.body.dataset.apiBaseUrl || "");
  let runtimeMode = configuredApiBaseUrl ? "api" : "guided";

  function formatRange(range, calorie = false) {
    const formatter = new Intl.NumberFormat(language, { maximumFractionDigits: 0 });
    const step = calorie ? 10 : 1;
    const low = Math.max(0, Math.round(Number(range[0]) / step) * step);
    const high = Math.max(low, Math.round(Number(range[1]) / step) * step);
    return `${formatter.format(low)}–${formatter.format(high)}`;
  }

  function formatFileSize(bytes) {
    if (bytes < 1024 * 1024) return `${Math.max(1, Math.round(bytes / 1024))} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  function shortFileName(name) {
    return name.length > 34 ? `${name.slice(0, 15)}…${name.slice(-15)}` : name;
  }

  function updateModeUi() {
    const apiMode = runtimeMode === "api";
    modeNote.classList.toggle("api-mode", apiMode);
    demoBodyElement.textContent = getCopy(apiMode ? "apiDemoBody" : "demoBody");
    idleKicker.textContent = getCopy(apiMode ? "apiIdleKicker" : "demoIdleKicker");
    idleTitle.textContent = getCopy(apiMode ? "apiIdleTitle" : "demoIdleTitle");
    idleBody.textContent = getCopy(apiMode ? "apiIdleBody" : "demoIdleBody");
    modeTitle.textContent = getCopy(apiMode ? "apiModeTitle" : "demoTruthTitle");
    modeBody.textContent = getCopy(apiMode ? "apiModeBody" : "demoTruthBody");
    guidedFields.forEach((field) => { field.hidden = apiMode; });
    demoButtonText.textContent = getCopy(apiMode ? "apiButton" : "demoButton");
  }

  function renderUploadStatus() {
    fileStatus.classList.toggle("is-error", Boolean(uploadErrorKey));
    formHelp.classList.toggle("is-error", Boolean(uploadErrorKey));
    if (uploadErrorKey) {
      fileStatus.textContent = getCopy(uploadErrorKey);
      formHelp.textContent = getCopy(uploadErrorKey);
      return;
    }
    if (!currentFile) {
      fileStatus.textContent = getCopy("uploadPrivacy");
      formHelp.textContent = getCopy("uploadFirst");
      return;
    }
    let handling = runtimeMode === "api" ? getCopy("fileWillUpload") : getCopy("fileLocal");
    if (uploadOutcome === "api") handling = getCopy("fileUploaded");
    if (uploadOutcome === "mock") handling = getCopy("fileMockUploaded");
    if (uploadOutcome === "attempted") handling = getCopy("fileRequestAttempted");
    fileStatus.textContent = `${getCopy("fileReady")}: ${shortFileName(currentFile.name)} · ${formatFileSize(currentFile.size)} · ${handling}.`;
    formHelp.textContent = getCopy(runtimeMode === "api" ? "readyApi" : "readyGuided");
  }

  function renderDynamicDemoCopy() {
    updateModeUi();
    renderUploadStatus();
    photoPreview.alt = language === "id" ? "Pratinjau foto makanan yang dipilih" : "Selected food photo preview";
    if (demoState === "loading") {
      const apiMode = runtimeMode === "api";
      loadingKicker.textContent = getCopy(apiMode ? "apiLoadingKicker" : "demoLoadingKicker");
      loadingTitle.textContent = getCopy(apiMode ? "apiLoadingOne" : "demoLoadingOne");
      loadingBody.textContent = getCopy(apiMode ? "apiLoadingBody" : "demoLoadingBody");
    }
    if (lastResult) renderResult(lastResult);
  }

  function showDemoPanel(panel) {
    [idlePanel, loadingPanel, resultPanel].forEach((item) => { item.hidden = item !== panel; });
  }

  function clearDemoTimers() {
    demoTimers.forEach((timer) => window.clearTimeout(timer));
    demoTimers = [];
  }

  function resetResult() {
    clearDemoTimers();
    requestSequence += 1;
    if (activeRequest) activeRequest.abort();
    activeRequest = null;
    lastResult = null;
    demoState = currentFile ? "ready" : "idle";
    demoShell.classList.remove("is-scanning");
    demoResult.setAttribute("aria-busy", "false");
    demoButton.disabled = !currentFile;
    showDemoPanel(idlePanel);
  }

  function clearPhoto() {
    resetResult();
    currentFile = null;
    uploadErrorKey = null;
    uploadOutcome = null;
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    previewUrl = null;
    photoPreview.removeAttribute("src");
    photoPreview.hidden = true;
    uploadStage.classList.remove("has-photo", "is-dragging");
    removePhotoButton.hidden = true;
    photoInput.value = "";
    cameraInput.value = "";
    demoButton.disabled = true;
    renderUploadStatus();
  }

  function setPhoto(file, source) {
    uploadErrorKey = null;
    if (!file || file.size === 0) {
      clearPhoto();
      uploadErrorKey = "fileEmpty";
      renderUploadStatus();
      return;
    }
    if (!ALLOWED_IMAGE_TYPES.has(file.type)) {
      clearPhoto();
      uploadErrorKey = "fileInvalid";
      renderUploadStatus();
      return;
    }
    if (file.size > MAX_IMAGE_BYTES) {
      clearPhoto();
      uploadErrorKey = "fileTooLarge";
      renderUploadStatus();
      return;
    }
    resetResult();
    runtimeMode = configuredApiBaseUrl ? "api" : "guided";
    currentFile = file;
    currentSource = source;
    uploadOutcome = null;
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    previewUrl = URL.createObjectURL(file);
    photoPreview.src = previewUrl;
    photoPreview.hidden = false;
    uploadStage.classList.add("has-photo");
    removePhotoButton.hidden = false;
    demoButton.disabled = false;
    demoState = "ready";
    updateModeUi();
    renderUploadStatus();
  }

  function setResultRow(index, label, value) {
    const row = resultRows[index];
    row.hidden = !label;
    if (!label) return;
    row.querySelector("[data-row-label]").textContent = label;
    row.querySelector("[data-row-value]").textContent = value;
  }

  function guidedEstimate(selection) {
    const preset = GUIDED_PRESETS[selection.meal] || GUIDED_PRESETS.other;
    const multiplier = PORTION_MULTIPLIERS[selection.portion] || 1;
    const oilAllowance = selection.oil ? [90, 130] : [0, 0];
    return {
      titleKey: preset.titleKey,
      calories: [preset.calories[0] * multiplier + oilAllowance[0], preset.calories[1] * multiplier + oilAllowance[1]],
      protein: [preset.protein[0] * multiplier, preset.protein[1] * multiplier],
      portionKey: PORTION_KEYS[selection.portion] || "portionMedium",
      oil: selection.oil,
    };
  }

  function validRange(value) {
    if (!value || !Number.isFinite(value.min) || !Number.isFinite(value.max)) return null;
    if (value.min < 0 || value.max < value.min) return null;
    return [value.min, value.max];
  }

  function normalizeApiResult(payload) {
    const calories = validRange(payload && payload.total && payload.total.calories);
    const protein = validRange(payload && payload.total && payload.total.protein_g);
    if (!calories || !protein || !Array.isArray(payload.foods)) throw new Error("invalid_response");
    const foods = payload.foods.slice(0, 3).map((food) => ({
      name: typeof food.name === "string" && food.name.trim() ? food.name.trim().slice(0, 80) : getCopy("unavailable"),
      quantity: Number.isFinite(food.quantity) && food.quantity > 0 ? Math.round(food.quantity) : null,
    }));
    return {
      provider: typeof payload.provider === "string" ? payload.provider : "unknown",
      confidence: Number.isFinite(payload.confidence) ? Math.min(1, Math.max(0, payload.confidence)) : null,
      calories,
      protein,
      foods,
    };
  }

  function renderResult(result) {
    if (result.kind === "guided") {
      const estimate = guidedEstimate(result.selection);
      const title = getCopy(estimate.titleKey);
      resultKicker.textContent = getCopy("guidedResultKicker");
      resultTitle.textContent = title;
      resultConfidence.textContent = getCopy("guidedConfidence");
      calorieResult.textContent = formatRange(estimate.calories, true);
      proteinResult.textContent = formatRange(estimate.protein);
      resultListTitle.textContent = getCopy("guidedListTitle");
      setResultRow(0, getCopy("mealInput"), title);
      setResultRow(1, getCopy("portionInput"), getCopy(estimate.portionKey));
      setResultRow(2, getCopy("oilInput"), getCopy(estimate.oil ? "yes" : "no"));
      resultNoteTitle.textContent = getCopy("guidedNoteTitle");
      resultNoteBody.textContent = getCopy("guidedNoteBody");
      resultDisclaimer.textContent = getCopy("guidedDisclaimer");
      return;
    }

    const apiResult = result.data;
    const mock = apiResult.provider === "mock_demo";
    const fallbackTitle = mock ? getCopy("mockResultKicker") : getCopy("apiResultKicker");
    resultKicker.textContent = fallbackTitle;
    resultTitle.textContent = apiResult.foods.length ? apiResult.foods.map((food) => food.name).slice(0, 2).join(" + ") : fallbackTitle;
    resultConfidence.textContent = mock
      ? getCopy("mockConfidence")
      : apiResult.confidence === null
        ? getCopy("unavailable")
        : `${Math.round(apiResult.confidence * 100)}%`;
    calorieResult.textContent = formatRange(apiResult.calories, true);
    proteinResult.textContent = formatRange(apiResult.protein);
    resultListTitle.textContent = getCopy(mock ? "mockFoodList" : "apiFoodList");
    resultRows.forEach((_, index) => {
      const food = apiResult.foods[index];
      setResultRow(index, food ? food.name : null, food && food.quantity ? `${food.quantity} g` : "—");
    });
    resultNoteTitle.textContent = getCopy(mock ? "mockNoteTitle" : "apiNoteTitle");
    resultNoteBody.textContent = getCopy(mock ? "mockNoteBody" : "apiNoteBody");
    resultDisclaimer.textContent = getCopy(mock ? "mockDisclaimer" : "apiDisclaimer");
  }

  function startLoading(mode) {
    clearDemoTimers();
    demoState = "loading";
    demoButton.disabled = true;
    demoShell.classList.add("is-scanning");
    demoResult.setAttribute("aria-busy", "true");
    loadingKicker.textContent = getCopy(mode === "api" ? "apiLoadingKicker" : "demoLoadingKicker");
    loadingTitle.textContent = getCopy(mode === "api" ? "apiLoadingOne" : "demoLoadingOne");
    loadingBody.textContent = getCopy(mode === "api" ? "apiLoadingBody" : "demoLoadingBody");
    showDemoPanel(loadingPanel);
    demoTimers.push(window.setTimeout(() => { loadingTitle.textContent = getCopy(mode === "api" ? "apiLoadingTwo" : "demoLoadingTwo"); }, 700));
    demoTimers.push(window.setTimeout(() => { loadingTitle.textContent = getCopy(mode === "api" ? "apiLoadingThree" : "demoLoadingThree"); }, 1450));
  }

  function finishLoading(result) {
    clearDemoTimers();
    activeRequest = null;
    demoState = "result";
    lastResult = result;
    demoButton.disabled = false;
    demoShell.classList.remove("is-scanning");
    demoResult.setAttribute("aria-busy", "false");
    renderResult(result);
    showDemoPanel(resultPanel);
  }

  async function reencodeForUpload(file) {
    let image = null;
    let temporaryUrl = null;
    try {
      if ("createImageBitmap" in window) {
        image = await createImageBitmap(file);
      } else {
        temporaryUrl = URL.createObjectURL(file);
        image = await new Promise((resolve, reject) => {
          const element = new Image();
          element.onload = () => resolve(element);
          element.onerror = () => reject(new Error("image_decode_failed"));
          element.src = temporaryUrl;
        });
      }
      const sourceWidth = image.width || image.naturalWidth;
      const sourceHeight = image.height || image.naturalHeight;
      if (!sourceWidth || !sourceHeight || sourceWidth * sourceHeight > 50000000) throw new Error("image_dimensions_invalid");
      const scale = Math.min(1, 1600 / Math.max(sourceWidth, sourceHeight));
      const canvas = document.createElement("canvas");
      canvas.width = Math.max(1, Math.round(sourceWidth * scale));
      canvas.height = Math.max(1, Math.round(sourceHeight * scale));
      const context = canvas.getContext("2d", { alpha: false });
      if (!context) throw new Error("canvas_unavailable");
      context.fillStyle = "#ffffff";
      context.fillRect(0, 0, canvas.width, canvas.height);
      context.drawImage(image, 0, 0, canvas.width, canvas.height);
      const blob = await new Promise((resolve, reject) => {
        canvas.toBlob((value) => value ? resolve(value) : reject(new Error("image_encode_failed")), "image/jpeg", 0.88);
      });
      if (blob.size > MAX_IMAGE_BYTES) throw new Error("encoded_image_too_large");
      return blob;
    } finally {
      if (image && typeof image.close === "function") image.close();
      if (temporaryUrl) URL.revokeObjectURL(temporaryUrl);
    }
  }

  async function requestPhotoAnalysis(sequence) {
    activeRequest = new AbortController();
    const timeout = window.setTimeout(() => activeRequest && activeRequest.abort(), 30000);
    try {
      const safeImage = await reencodeForUpload(currentFile);
      if (sequence !== requestSequence) return;
      const data = new FormData();
      data.append("image", safeImage, "meal-photo.jpg");
      data.append("locale", language);
      data.append("source", currentSource);
      uploadOutcome = "attempted";
      renderUploadStatus();
      const response = await fetch(`${configuredApiBaseUrl}/v1/analyze`, {
        method: "POST",
        body: data,
        mode: "cors",
        credentials: "omit",
        referrerPolicy: "strict-origin-when-cross-origin",
        signal: activeRequest.signal,
      });
      if (!response.ok) throw new Error("request_failed");
      const result = normalizeApiResult(await response.json());
      if (sequence !== requestSequence) return;
      uploadOutcome = result.provider === "mock_demo" ? "mock" : "api";
      if (result.provider === "mock_demo") runtimeMode = "guided";
      finishLoading({ kind: "api", data: result });
      updateModeUi();
      renderUploadStatus();
    } catch (_) {
      if (sequence !== requestSequence) return;
      clearDemoTimers();
      activeRequest = null;
      uploadOutcome = "attempted";
      runtimeMode = "guided";
      demoState = "ready";
      demoButton.disabled = false;
      demoShell.classList.remove("is-scanning");
      demoResult.setAttribute("aria-busy", "false");
      showDemoPanel(idlePanel);
      updateModeUi();
      formHelp.textContent = getCopy("apiFailed");
      formHelp.classList.add("is-error");
    } finally {
      window.clearTimeout(timeout);
    }
  }

  analysisForm.addEventListener("submit", (event) => {
    event.preventDefault();
    if (!currentFile) {
      uploadErrorKey = "uploadFirst";
      renderUploadStatus();
      photoInput.focus();
      return;
    }
    uploadErrorKey = null;
    requestSequence += 1;
    const sequence = requestSequence;
    if (runtimeMode === "api") {
      startLoading("api");
      requestPhotoAnalysis(sequence);
      return;
    }
    startLoading("guided");
    const selection = { meal: mealSelect.value, portion: portionSelect.value, oil: extraOil.checked };
    demoTimers.push(window.setTimeout(() => {
      if (sequence === requestSequence) finishLoading({ kind: "guided", selection });
    }, 1900));
  });

  photoInput.addEventListener("change", () => setPhoto(photoInput.files[0], "gallery"));
  cameraInput.addEventListener("change", () => setPhoto(cameraInput.files[0], "camera"));
  removePhotoButton.addEventListener("click", clearPhoto);
  adjustEstimateButton.addEventListener("click", () => {
    lastResult = null;
    demoState = "ready";
    showDemoPanel(idlePanel);
    updateModeUi();
    renderUploadStatus();
  });

  uploadStage.addEventListener("click", () => photoInput.click());
  uploadStage.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      photoInput.click();
    }
  });
  ["dragenter", "dragover"].forEach((type) => uploadStage.addEventListener(type, (event) => {
    event.preventDefault();
    uploadStage.classList.add("is-dragging");
  }));
  ["dragleave", "drop"].forEach((type) => uploadStage.addEventListener(type, (event) => {
    event.preventDefault();
    uploadStage.classList.remove("is-dragging");
  }));
  uploadStage.addEventListener("drop", (event) => {
    const file = event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files[0];
    if (file) setPhoto(file, "gallery");
  });
  photoPreview.addEventListener("error", () => {
    clearPhoto();
    uploadErrorKey = "fileInvalid";
    renderUploadStatus();
  });
  window.addEventListener("beforeunload", () => {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    if (activeRequest) activeRequest.abort();
  });

  setLanguage(initialLanguage, false);

  document.querySelectorAll("[data-scroll-demo]").forEach((button) => {
    button.addEventListener("click", () => document.querySelector("#demo").scrollIntoView({ behavior: "smooth" }));
  });

  function inferRepositoryUrl() {
    if (!window.location.hostname.endsWith(".github.io")) return null;
    const owner = window.location.hostname.split(".")[0];
    const firstPath = window.location.pathname.split("/").filter(Boolean)[0];
    const repository = firstPath || `${owner}.github.io`;
    return `https://github.com/${owner}/${repository}`;
  }

  const repositoryUrl = document.body.dataset.repositoryUrl || inferRepositoryUrl();
  if (repositoryUrl) {
    document.querySelectorAll(".repo-link").forEach((link) => {
      link.href = repositoryUrl;
      link.target = "_blank";
      link.rel = "noopener noreferrer";
    });
  }

  document.querySelector("[data-year]").textContent = new Date().getFullYear();

  const revealElements = [...document.querySelectorAll(".reveal")];
  if ("IntersectionObserver" in window && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -30px" });
    revealElements.forEach((element) => observer.observe(element));
  } else {
    revealElements.forEach((element) => element.classList.add("is-visible"));
  }
})();
