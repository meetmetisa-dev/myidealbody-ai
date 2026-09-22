import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../state/app_scope.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;
  bool _consent = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = AppScope.of(context);
    final items = [
      _OnboardingItem(
        icon: Icons.center_focus_strong_rounded,
        title: l10n.onboardingPhotoTitle,
        body: l10n.onboardingPhotoBody,
        accent: const Color(0xFF0A7A65),
      ),
      _OnboardingItem(
        icon: Icons.tune_rounded,
        title: l10n.onboardingHonestTitle,
        body: l10n.onboardingHonestBody,
        accent: const Color(0xFF6655C6),
      ),
      _OnboardingItem(
        icon: Icons.rice_bowl_rounded,
        title: l10n.onboardingLocalTitle,
        body: l10n.onboardingLocalBody,
        accent: const Color(0xFFEC7D42),
      ),
      _OnboardingItem(
        icon: Icons.privacy_tip_outlined,
        title: l10n.onboardingPrivacyTitle,
        body: l10n.onboardingPrivacyBody,
        accent: const Color(0xFF1676A3),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Spacer(),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('EN')),
                      ButtonSegment(value: 'id', label: Text('ID')),
                    ],
                    selected: {controller.locale.languageCode},
                    onSelectionChanged: (value) =>
                        controller.setLocale(Locale(value.first)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: items.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) => _OnboardingPage(
                  item: items[index],
                  showConsent: index == items.length - 1,
                  consent: _consent,
                  onConsentChanged: (value) => setState(() => _consent = value),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: index == _index ? 28 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == _index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      if (_index < items.length - 1) {
                        _pages.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        controller.completeOnboarding(consent: _consent);
                      }
                    },
                    child: Text(
                      _index == items.length - 1
                          ? l10n.continueLabel
                          : l10n.next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.item,
    required this.showConsent,
    required this.consent,
    required this.onConsentChanged,
  });

  final _OnboardingItem item;
  final bool showConsent;
  final bool consent;
  final ValueChanged<bool> onConsentChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 16),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: item.accent.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 72, color: item.accent),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            item.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (showConsent) ...[
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: consent,
                      onChanged: (value) => onConsentChanged(value ?? false),
                      title: Text(l10n.cloudConsentLabel),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.cloudConsentHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.estimateDisclaimer}\n${l10n.medicalDisclaimer}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;
}

