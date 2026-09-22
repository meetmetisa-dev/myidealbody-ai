abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Safe by default: the fixed-result demo runs locally and does not make an
  // analysis request or transmit the user's selected photo. A production
  // build must explicitly opt in only after its API and disclosures are ready.
  static const demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );

  // Permanent Google Play application ID. Changing this creates a different
  // app and must be treated as a release-blocking configuration error.
  static const androidPackageName = 'com.myidealbody.ai';
  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.1.0',
  );
  static const privacyPolicyUrl =
      'https://meetmetisa-dev.github.io/myidealbody-ai/privacy.html';
  static const termsOfUseUrl =
      'https://meetmetisa-dev.github.io/myidealbody-ai/terms.html';
  static const supportUrl =
      'https://meetmetisa-dev.github.io/myidealbody-ai/support.html';
  static const monthlyProductId = 'myidealbody_pro_monthly';
  static const annualProductId = 'myidealbody_pro_annual';
  static const freeDailyScans = 3;
}
