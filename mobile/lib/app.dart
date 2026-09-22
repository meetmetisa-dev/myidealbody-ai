import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_scope.dart';

class MyIdealBodyApp extends StatelessWidget {
  const MyIdealBodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      locale: controller.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: controller.onboardingComplete
            ? const MainShell(key: ValueKey('main'))
            : const OnboardingScreen(key: ValueKey('onboarding')),
      ),
    );
  }
}
