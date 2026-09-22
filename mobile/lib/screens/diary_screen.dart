import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../l10n/l10n.dart';
import '../models/nutrition_models.dart';
import '../state/app_scope.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _day = DateTime.now();

  bool get _isToday {
    final now = DateTime.now();
    return _day.year == now.year && _day.month == now.month && _day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    final entries = controller.entriesFor(_day).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final calories = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.calories.estimated,
    );
    final protein = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.protein.estimated,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diaryTitle),
        automaticallyImplyLeading: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList.list(
              children: [
                _DayPicker(
                  day: _day,
                  isToday: _isToday,
                  locale: controller.locale.languageCode,
                  onPrevious: () => setState(
                    () => _day = _day.subtract(const Duration(days: 1)),
                  ),
                  onNext: _isToday
                      ? null
                      : () => setState(
                            () => _day = _day.add(const Duration(days: 1)),
                          ),
                ),
                const SizedBox(height: 18),
                Text(l10n.dailyTotal, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DiaryTotal(
                            icon: Icons.local_fire_department_rounded,
                            color: AppTheme.calories,
                            label: l10n.calories,
                            value: '${calories.round()} ${l10n.kcal}',
                          ),
                        ),
                        SizedBox(
                          height: 54,
                          child: VerticalDivider(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        Expanded(
                          child: _DiaryTotal(
                            icon: Icons.fitness_center_rounded,
                            color: AppTheme.protein,
                            label: l10n.protein,
                            value: '${protein.round()} ${l10n.gramsShort}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (entries.isEmpty)
                  const _EmptyDiary()
                else
                  ...entries.map(
                    (entry) => _DiaryMealCard(
                      entry: entry,
                      locale: controller.locale.languageCode,
                      onDelete: () => _confirmDelete(entry),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(DiaryEntry entry) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: Text(l10n.deleteMealTitle),
        content: Text(l10n.deleteMealBody),
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
    if (confirmed == true && mounted) {
      await AppScope.of(context).deleteDiaryEntry(entry.id);
    }
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.day,
    required this.isToday,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime day;
  final bool isToday;
  final String locale;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton.filledTonal(
            onPressed: onPrevious,
            tooltip: context.l10n.previousDay,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  isToday ? context.l10n.today : DateFormat.EEEE(locale).format(day),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  DateFormat.yMMMMd(locale).format(day),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onNext,
            tooltip: context.l10n.nextDay,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      );
}

class _DiaryTotal extends StatelessWidget {
  const _DiaryTotal({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$label, $value',
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(label),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
}

class _DiaryMealCard extends StatelessWidget {
  const _DiaryMealCard({
    required this.entry,
    required this.locale,
    required this.onDelete,
  });

  final DiaryEntry entry;
  final String locale;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confidenceText = entry.confidence >= .75
        ? l10n.confidenceHigh
        : entry.confidence >= .5
            ? l10n.confidenceMedium
            : l10n.confidenceLow;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.restaurant_rounded),
        ),
        title: Text(entry.mealLabel),
        subtitle: Text(
          '${DateFormat.Hm(locale).format(entry.createdAt)} · '
          '${entry.calories.estimated.round()} ${l10n.kcal} · '
          '${entry.protein.estimated.round()} ${l10n.gramsShort} ${l10n.protein.toLowerCase()}',
        ),
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: l10n.delete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
        children: [
          const Divider(height: 1),
          ...entry.foods.map(
            (food) => ListTile(
              dense: true,
              title: Text(food.name),
              subtitle: Text('${food.quantity} ${food.unit}'),
              trailing: Text(
                '${food.calories.estimated.round()} ${l10n.kcal}\n'
                '${food.protein.estimated.round()} ${l10n.gramsShort} ${l10n.protein.toLowerCase()}',
                textAlign: TextAlign.end,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 17),
                const SizedBox(width: 7),
                Text(
                  '${l10n.confidence}: $confidenceText',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDiary extends StatelessWidget {
  const _EmptyDiary();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(l10n.emptyDiaryTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(l10n.emptyDiaryBody, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
