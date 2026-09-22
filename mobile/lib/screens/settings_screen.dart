import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';
import '../l10n/l10n.dart';
import '../state/app_scope.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        children: [
          _SectionTitle(l10n.language),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                expandedInsets: EdgeInsets.zero,
                showSelectedIcon: true,
                segments: [
                  ButtonSegment(value: 'en', label: Text(l10n.english)),
                  ButtonSegment(value: 'id', label: Text(l10n.indonesian)),
                ],
                selected: {controller.locale.languageCode},
                onSelectionChanged: (selection) =>
                    controller.setLocale(Locale(selection.first)),
              ),
            ),
          ),
          _SectionTitle(l10n.goals),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              leading: const Icon(Icons.track_changes_rounded),
              title: Text(l10n.editGoals),
              subtitle: Text(
                '${controller.calorieGoal.round()} ${l10n.kcal} · '
                '${controller.proteinGoal.round()} ${l10n.gramsShort} ${l10n.protein.toLowerCase()}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _editGoals(context),
            ),
          ),
          _SectionTitle(l10n.privacy),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.cloud_upload_outlined),
                  title: Text(l10n.cloudAnalysis),
                  subtitle: Text(l10n.cloudAnalysisDescription),
                  value: !controller.api.isDemoMode && controller.cloudAnalysisConsent,
                  onChanged:
                      controller.api.isDemoMode ? null : controller.setCloudConsent,
                ),
                const Divider(height: 1, indent: 18, endIndent: 18),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: Text(l10n.privacyPolicy),
                  subtitle: Text(l10n.photoRetentionMvp),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 19),
                  onTap: () => _openExternalPage(
                    context,
                    AppConfig.privacyPolicyUrl,
                  ),
                ),
                const Divider(height: 1, indent: 18, endIndent: 18),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(l10n.clearHistory),
                  subtitle: Text(l10n.localData),
                  onTap: () => _clearData(context),
                ),
              ],
            ),
          ),
          _SectionTitle(l10n.subscription),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(controller.isPro ? l10n.proActive : l10n.upgradeToPro),
              subtitle: Text(
                controller.isPro ? l10n.unlimitedScans : l10n.monthlyPreviewPrice,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PaywallScreen()),
              ),
            ),
          ),
          _SectionTitle(l10n.about),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.termsOfUse),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 19),
                  onTap: () => _openExternalPage(
                    context,
                    AppConfig.termsOfUseUrl,
                  ),
                ),
                const Divider(height: 1, indent: 18, endIndent: 18),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: Text(l10n.support),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 19),
                  onTap: () => _openExternalPage(
                    context,
                    AppConfig.supportUrl,
                  ),
                ),
                const Divider(height: 1, indent: 18, endIndent: 18),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l10n.appName),
                  subtitle: Text('${l10n.versionLabel} ${AppConfig.appVersion}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.health_and_safety_outlined),
                const SizedBox(height: 8),
                Text(
                  '${l10n.estimateDisclaimer}\n\n${l10n.medicalDisclaimer}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editGoals(BuildContext context) async {
    final controller = AppScope.of(context);
    final calories = TextEditingController(text: controller.calorieGoal.round().toString());
    final protein = TextEditingController(text: controller.proteinGoal.round().toString());
    final result = await showModalBottomSheet<(double, double)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.editGoals, style: Theme.of(sheetContext).textTheme.headlineSmall),
              const SizedBox(height: 18),
              TextField(
                controller: calories,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.calorieGoal,
                  suffixText: l10n.kcal,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: protein,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.proteinGoal,
                  suffixText: l10n.gramsShort,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  final calorieValue = double.tryParse(calories.text);
                  final proteinValue = double.tryParse(protein.text);
                  if (calorieValue == null || proteinValue == null) return;
                  Navigator.pop(sheetContext, (calorieValue, proteinValue));
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
    calories.dispose();
    protein.dispose();
    if (result != null && context.mounted) {
      await controller.setGoals(calories: result.$1, protein: result.$2);
    }
  }

  Future<void> _clearData(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: Text(l10n.clearHistoryTitle),
        content: Text(l10n.clearHistoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await AppScope.of(context).clearDiaryData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.dataDeleted)),
    );
  }

  Future<void> _openExternalPage(BuildContext context, String rawUrl) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(rawUrl),
        mode: LaunchMode.externalApplication,
      );
    } on Exception {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.linkOpenFailed)),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}
