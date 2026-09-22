(() => {
  "use strict";

  document.documentElement.classList.add("js");

  const copyElements = [...document.querySelectorAll("[data-i18n]")];
  const ariaElements = [...document.querySelectorAll("[data-i18n-aria]")];
  const english = Object.fromEntries(copyElements.map((element) => [element.dataset.i18n, element.textContent.trim()]));
  Object.assign(english, {
    demoLoadingTwo: "Estimating portions…",
    demoLoadingThree: "Calculating nutrition…",
    demoAgain: "Run sample again",
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
    demoKicker: "Pratinjau produk interaktif",
    demoTitle: "Lihat bagaimana makanan menjadi estimasi yang dapat diperiksa.",
    demoBody: "Demo browser ini menggunakan contoh makanan tetap. Demo tidak mengunggah foto atau menjalankan model produksi.",
    demoCamera: "Panduan kamera",
    demoHint: "Seluruh piring di dalam bingkai",
    demoButton: "Analisis contoh makanan",
    demoIdleKicker: "Siap saat kamu siap",
    demoIdleTitle: "Mulai dengan piring contoh",
    demoIdleBody: "Pratinjau akan menampilkan contoh rentang, makanan yang terdeteksi, tingkat keyakinan, dan pertanyaan klarifikasi.",
    demoLoadingKicker: "Analisis contoh",
    demoLoadingOne: "Mengenali kemungkinan makanan…",
    demoLoadingTwo: "Memperkirakan porsi…",
    demoLoadingThree: "Menghitung informasi gizi…",
    demoLoadingBody: "Hasil produksi akan dihitung dari basis data gizi setelah proses pengenalan.",
    demoResultKicker: "Contoh estimasi",
    demoResultTitle: "Piring makan siang",
    demoConfidence: "Keyakinan sedang",
    demoCalories: "Kalori",
    demoProtein: "Protein",
    demoRangeNote: "Rentang mencerminkan kemungkinan perbedaan porsi dan resep.",
    demoDetected: "Kemungkinan makanan",
    demoEdit: "Periksa di aplikasi",
    foodRice: "Nasi putih",
    foodChicken: "Ayam bakar",
    foodTempe: "Tempe",
    foodVeg: "Sayuran campur",
    demoQuestionTitle: "Satu pemeriksaan singkat",
    demoQuestionBody: "Apakah ada tambahan minyak atau saus manis?",
    demoDisclaimer: "Hanya contoh ilustrasi. Bukan pengukuran atau saran medis.",
    demoAgain: "Ulangi contoh",
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
    faqThreeA: "Prototipe menampilkan bingkai panduan dan indikator pencahayaan langsung, lalu menganalisis satu foto diam. Pendekatan ini mengurangi penggunaan baterai dan data serta membuat tahap pemeriksaan tetap jelas.",
    faqFourQ: "Apakah ini saran medis atau dietetik?",
    faqFourA: "Bukan. Produk hanya memberi estimasi untuk kebugaran umum dan bukan diagnosis, perawatan, pengukuran laboratorium, atau pengganti tenaga profesional.",
    footerTagline: "Titik awal yang praktis dan jujur untuk pencatatan gizi sehari-hari.",
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
    mealArt: "Ilustrasi nasi, ayam bakar, tempe, dan sayuran di atas piring",
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
    renderDemoButton();
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
  const demoButton = document.querySelector("[data-demo-button]");
  const demoButtonText = demoButton.querySelector("[data-i18n]");
  const demoResult = document.querySelector("[data-demo-result]");
  const idlePanel = document.querySelector("[data-result-idle]");
  const loadingPanel = document.querySelector("[data-result-loading]");
  const resultPanel = document.querySelector("[data-result-content]");
  const loadingTitle = document.querySelector("[data-demo-loading-title]");

  setLanguage(initialLanguage, false);

  function renderDemoButton() {
    if (!demoButtonText) return;
    demoButtonText.textContent = demoState === "result" ? getCopy("demoAgain") : getCopy("demoButton");
  }

  function showDemoPanel(panel) {
    [idlePanel, loadingPanel, resultPanel].forEach((item) => { item.hidden = item !== panel; });
  }

  function clearDemoTimers() {
    demoTimers.forEach((timer) => window.clearTimeout(timer));
    demoTimers = [];
  }

  demoButton.addEventListener("click", () => {
    clearDemoTimers();
    demoState = "loading";
    renderDemoButton();
    demoButton.disabled = true;
    demoShell.classList.add("is-scanning");
    demoResult.setAttribute("aria-busy", "true");
    loadingTitle.textContent = getCopy("demoLoadingOne");
    showDemoPanel(loadingPanel);

    demoTimers.push(window.setTimeout(() => { loadingTitle.textContent = getCopy("demoLoadingTwo"); }, 850));
    demoTimers.push(window.setTimeout(() => { loadingTitle.textContent = getCopy("demoLoadingThree"); }, 1700));
    demoTimers.push(window.setTimeout(() => {
      demoState = "result";
      demoButton.disabled = false;
      demoShell.classList.remove("is-scanning");
      demoResult.setAttribute("aria-busy", "false");
      showDemoPanel(resultPanel);
      renderDemoButton();
    }, 2600));
  });

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
