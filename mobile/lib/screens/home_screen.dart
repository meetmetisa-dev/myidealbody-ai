import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../l10n/l10n.dart';
import '../models/nutrition_models.dart';
import '../state/app_scope.dart';
import '../widgets/nutrient_card.dart';
import 'paywall_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onShowDiary, super.key});

  final VoidCallback onShowDiary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = AppScope.of(context);
    final now = DateTime.now();
    final entries = controller.entriesFor(now).toList();
    final calories = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.calories.estimated,
    );
    final protein = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.protein.estimated,
    );
    final greeting = now.hour < 12
        ? l10n.goodMorning
        : now.hour < 18
            ? l10n.goodAfternoon
            : l10n.goodEvening;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              DateFormat.yMMMMEEEEd(controller.locale.languageCode)
                                  .format(now),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.isPro)
                        const _ProChip()
                      else
                        IconButton.filledTonal(
                          tooltip: l10n.upgradeToPro,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PaywallScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.workspace_premium_rounded),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.dailyOverview,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: NutrientCard(
                          label: l10n.calories,
                          value: calories,
                          goal: controller.calorieGoal,
                          unit: l10n.kcal,
                          color: AppTheme.calories,
                          goalText: l10n.ofGoal(
                            controller.calorieGoal.round().toString(),
                            l10n.kcal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NutrientCard(
                          label: l10n.protein,
                          value: protein,
                          goal: controller.proteinGoal,
                          unit: l10n.gramsShort,
                          color: AppTheme.protein,
                          goalText: l10n.ofGoal(
                            controller.proteinGoal.round().toString(),
                            l10n.gramsShort,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!controller.goalsConfigured) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.exampleGoalsNote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _ScanCard(
                    scansLabel: controller.api.isDemoMode
                        ? l10n.localDemoLabel
                        : controller.isPro
                            ? l10n.unlimitedScans
                            : l10n.scansRemaining(controller.freeScansRemaining),
                    isDemo: controller.api.isDemoMode,
                    onCamera: () => _openScan(context, openGallery: false),
                    onGallery: () => _openScan(context, openGallery: true),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.recentMeals,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (entries.isNotEmpty)
                        TextButton(onPressed: onShowDiary, child: Text(l10n.seeAll)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (entries.isEmpty)
                    _EmptyMeals(onScan: () => _openScan(context, openGallery: false))
                  else
                    ...entries.take(3).map((entry) => _MealTile(entry: entry)),
                  const SizedBox(height: 20),
                  Text(
                    l10n.estimateDisclaimer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Future<void> _openScan(BuildContext context, {required bool openGallery}) async {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    if (!controller.canScan) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PaywallScreen()),
      );
      return;
    }
    if (!controller.api.isDemoMode && !controller.cloudAnalysisConsent) {
      final allowed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.cloud_upload_outlined),
          title: Text(l10n.cloudConsentRequiredTitle),
          content: Text(l10n.cloudConsentRequiredBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.notNow),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.allowAndContinue),
            ),
          ],
        ),
      );
      if (allowed != true || !context.mounted) return;
      await controller.setCloudConsent(true);
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanScreen(openGalleryOnStart: openGallery),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({
    required this.scansLabel,
    required this.isDemo,
    required this.onCamera,
    required this.onGallery,
  });

  final String scansLabel;
  final bool isDemo;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, const Color(0xFF075747)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              scansLabel,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l10n.scanMeal,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            isDemo ? l10n.demoScanSubtitle : l10n.scanMealSubtitle,
            style: const TextStyle(color: Color(0xFFDDF4EE), height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCamera,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colors.primary,
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(l10n.scanMeal),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: onGallery,
                tooltip: l10n.choosePhoto,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .15),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(54, 54),
                ),
                icon: const Icon(Icons.photo_library_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.restaurant_rounded),
        ),
        title: Text(entry.mealLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          DateFormat.Hm(controller.locale.languageCode).format(entry.createdAt),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.calories.estimated.round()} ${l10n.kcal}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text('${entry.protein.estimated.round()} ${l10n.gramsShort} ${l10n.protein.toLowerCase()}'),
          ],
        ),
      ),
    );
  }
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.no_meals_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(l10n.noMealsToday, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.noMealsTodayBody, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onScan, child: Text(l10n.scanMeal)),
          ],
        ),
      ),
    );
  }
}

class _ProChip extends StatelessWidget {
  const _ProChip();

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.workspace_premium_rounded, size: 18),
        label: Text(context.l10n.proActive),
      );
}
