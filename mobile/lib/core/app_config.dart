abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Safe by default: the source MVP sends a generated placeholder to the
  // fixed mock backend instead of transmitting the user's selected photo.
  // A production build must opt in only after a real provider and reviewed
  // privacy disclosures are configured.
  static const demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );

  static const androidPackageName = 'com.myidealbody.ai';
  static const monthlyProductId = 'myidealbody_pro_monthly';
  static const annualProductId = 'myidealbody_pro_annual';
  static const freeDailyScans = 3;
}
