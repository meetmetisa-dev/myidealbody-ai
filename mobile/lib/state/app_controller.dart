import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_config.dart';
import '../models/nutrition_models.dart';
import '../services/api_service.dart';
import '../services/subscription_service.dart';

class AppController extends ChangeNotifier {
  AppController._(this._preferences, this.api);

  static const _onboardingKey = 'onboarding_complete';
  static const _localeKey = 'locale';
  static const _cloudConsentKey = 'cloud_analysis_consent';
  static const _diaryKey = 'diary_entries_v1';
  static const _scanHistoryKey = 'scan_history_v1';
  static const _calorieGoalKey = 'calorie_goal';
  static const _proteinGoalKey = 'protein_goal';

  final SharedPreferences _preferences;
  final ApiService api;
  late final SubscriptionService subscriptions;

  Locale locale = const Locale('en');
  bool onboardingComplete = false;
  bool cloudAnalysisConsent = false;
  bool isPro = false;
  bool goalsConfigured = false;
  double calorieGoal = 2000;
  double proteinGoal = 120;
  List<DiaryEntry> diary = [];
  List<DateTime> _scanHistory = [];

  static Future<AppController> load({ApiService? api}) async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController._(preferences, api ?? ApiService());
    await controller._restore();
    controller.subscriptions = SubscriptionService(
      api: controller.api,
      onEntitlementChanged: controller.setProEntitlement,
    );
    return controller;
  }

  Future<void> _restore() async {
    onboardingComplete = _preferences.getBool(_onboardingKey) ?? false;
    cloudAnalysisConsent = _preferences.getBool(_cloudConsentKey) ?? false;
    // Never trust a cached subscription across launches. The Play purchase is
    // restored and verified against the backend when billing is configured.
    isPro = false;
    goalsConfigured = _preferences.containsKey(_calorieGoalKey) &&
        _preferences.containsKey(_proteinGoalKey);
    calorieGoal = _preferences.getDouble(_calorieGoalKey) ?? 2000;
    proteinGoal = _preferences.getDouble(_proteinGoalKey) ?? 120;
    diary = decodeDiary(_preferences.getString(_diaryKey));

    final savedLocale = _preferences.getString(_localeKey);
    final systemLanguage = PlatformDispatcher.instance.locale.languageCode;
    locale = Locale(savedLocale ?? (systemLanguage == 'id' ? 'id' : 'en'));

    _scanHistory = (_preferences.getStringList(_scanHistoryKey) ?? const [])
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .toList();
    _removeOldScans();
    await _preferences.setStringList(
      _scanHistoryKey,
      _scanHistory.map((date) => date.toIso8601String()).toList(),
    );
  }

  int get scansToday {
    final now = DateTime.now();
    return _scanHistory
        .where((time) =>
            time.year == now.year && time.month == now.month && time.day == now.day)
        .length;
  }

  int get freeScansRemaining =>
      (AppConfig.freeDailyScans - scansToday)
          .clamp(0, AppConfig.freeDailyScans)
          .toInt();

  bool get canScan => isPro || freeScansRemaining > 0;

  Iterable<DiaryEntry> entriesFor(DateTime day) => diary.where(
        (entry) =>
            entry.createdAt.year == day.year &&
            entry.createdAt.month == day.month &&
            entry.createdAt.day == day.day,
      );

  Future<void> completeOnboarding({required bool consent}) async {
    onboardingComplete = true;
    cloudAnalysisConsent = consent;
    await Future.wait([
      _preferences.setBool(_onboardingKey, true),
      _preferences.setBool(_cloudConsentKey, consent),
    ]);
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    if (value.languageCode != 'en' && value.languageCode != 'id') return;
    locale = value;
    await _preferences.setString(_localeKey, value.languageCode);
    notifyListeners();
  }

  Future<void> setCloudConsent(bool value) async {
    cloudAnalysisConsent = value;
    await _preferences.setBool(_cloudConsentKey, value);
    notifyListeners();
  }

  Future<void> setGoals({required double calories, required double protein}) async {
    calorieGoal = calories.clamp(800, 6000).toDouble();
    proteinGoal = protein.clamp(20, 400).toDouble();
    goalsConfigured = true;
    await Future.wait([
      _preferences.setDouble(_calorieGoalKey, calorieGoal),
      _preferences.setDouble(_proteinGoalKey, proteinGoal),
    ]);
    notifyListeners();
  }

  Future<void> recordSuccessfulScan() async {
    _scanHistory.add(DateTime.now());
    _removeOldScans();
    await _preferences.setStringList(
      _scanHistoryKey,
      _scanHistory.map((date) => date.toIso8601String()).toList(),
    );
    notifyListeners();
  }

  Future<void> addDiaryEntry(DiaryEntry entry) async {
    diary = [entry, ...diary.where((item) => item.id != entry.id)];
    await _saveDiary();
    notifyListeners();
  }

  Future<void> deleteDiaryEntry(String id) async {
    diary = diary.where((entry) => entry.id != id).toList();
    await _saveDiary();
    notifyListeners();
  }

  Future<void> clearDiaryData() async {
    diary = [];
    await _preferences.remove(_diaryKey);
    notifyListeners();
  }

  Future<void> setProEntitlement(bool active) {
    isPro = active;
    notifyListeners();
    return Future<void>.value();
  }

  void _removeOldScans() {
    final cutoff = DateTime.now().subtract(const Duration(days: 2));
    _scanHistory = _scanHistory.where((time) => time.isAfter(cutoff)).toList();
  }

  Future<void> _saveDiary() => _preferences.setString(_diaryKey, encodeDiary(diary));

  @override
  void dispose() {
    subscriptions.dispose();
    super.dispose();
  }
}
