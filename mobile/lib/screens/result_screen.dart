import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../l10n/l10n.dart';
import '../models/nutrition_models.dart';
import '../state/app_scope.dart';
import 'paywall_screen.dart';
import 'scan_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.initialAnalysis,
    required this.imagePath,
    required this.source,
    super.key,
  });

  final MealAnalysis initialAnalysis;
  final String imagePath;
  final String source;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late List<FoodEstimate> _foods;
  TextEditingController? _mealName;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _foods = [...widget.initialAnalysis.foods];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mealName ??= TextEditingController(text: context.l10n.mealNameDefault);
  }

  @override
  void dispose() {
    _deleteCameraTemp();
    _mealName?.dispose();
    super.dispose();
  }

  NutrientRange get _calories => _sumRanges(
        fallback: widget.initialAnalysis.calories,
        select: (food) => food.calories,
      );

  NutrientRange get _protein => _sumRanges(
        fallback: widget.initialAnalysis.protein,
        select: (food) => food.protein,
      );

  NutrientRange get _carbs => _sumRanges(
        fallback: widget.initialAnalysis.carbs,
        select: (food) => food.carbs,
      );

  NutrientRange get _fat => _sumRanges(
        fallback: widget.initialAnalysis.fat,
        select: (food) => food.fat,
      );

  NutrientRange _sumRanges({
    required NutrientRange fallback,
    required NutrientRange Function(FoodEstimate food) select,
  }) {
    if (_foods.isEmpty && widget.initialAnalysis.foods.isEmpty) return fallback;
    var min = 0.0;
    var max = 0.0;
    var estimated = 0.0;
    for (final food in _foods) {
      final value = select(food);
      min += value.min;
      max += value.max;
      estimated += value.estimated;
    }
    return NutrientRange(min: min, max: max, estimated: estimated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDemo = widget.initialAnalysis.provider == 'mock_demo';
    final confidence = widget.initialAnalysis.confidence;
    final confidenceText = confidence >= .75
        ? l10n.confidenceHigh
        : confidence >= .5
            ? l10n.confidenceMedium
            : l10n.confidenceLow;
    final confidenceColor = confidence >= .75
        ? const Color(0xFF177A59)
        : confidence >= .5
            ? const Color(0xFF9A6411)
            : Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        actions: [
          IconButton(
            onPressed: _retake,
            tooltip: l10n.retakePhoto,
            icon: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          if (isDemo) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.science_outlined,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.demoModeTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.demoModeBody,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (File(widget.imagePath).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  semanticLabel: l10n.resultTitle,
                ),
              ),
            ),
          const SizedBox(height: 18),
          TextField(
            controller: _mealName,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.mealName,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 16),
          if (!isDemo) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: confidenceColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: confidenceColor.withValues(alpha: .3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    confidence >= .5
                        ? Icons.fact_check_outlined
                        : Icons.help_outline_rounded,
                    color: confidenceColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.confidence}: $confidenceText',
                          style: TextStyle(
                            color: confidenceColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (confidence < .5) ...[
                          const SizedBox(height: 4),
                          Text(l10n.reviewLowConfidence),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],
          Text(l10n.estimatedRange, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RangeCard(
                  label: l10n.calories,
                  value: _calories,
                  unit: l10n.kcal,
                  icon: Icons.local_fire_department_rounded,
                  color: AppTheme.calories,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RangeCard(
                  label: l10n.protein,
                  value: _protein,
                  unit: l10n.gramsShort,
                  icon: Icons.fitness_center_rounded,
                  color: AppTheme.protein,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SmallMacro(label: l10n.carbs, value: _carbs, unit: l10n.gramsShort),
                  SizedBox(
                    height: 38,
                    child: VerticalDivider(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  _SmallMacro(label: l10n.fat, value: _fat, unit: l10n.gramsShort),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isDemo ? l10n.sampleFoods : l10n.detectedFoods,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _foods.length,
            (index) => _FoodCard(
              food: _foods[index],
              onEdit: () => _editFood(index),
            ),
          ),
          if (widget.initialAnalysis.questions.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(l10n.questionsTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...widget.initialAnalysis.questions.map(
              (question) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: question.options
                            .map(
                              (option) => Chip(
                                avatar: const Icon(Icons.check_box_outline_blank, size: 16),
                                label: Text(option.label),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.reviewPromptsNote,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(l10n.thingsToCheck, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Caveat(text: l10n.hiddenIngredientsHint),
                  ...widget.initialAnalysis.caveats.map((item) => _Caveat(text: item)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${l10n.estimateDisclaimer}\n${l10n.medicalDisclaimer}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: FilledButton.icon(
          onPressed: isDemo || _saved ? null : _save,
          icon: Icon(
            isDemo
                ? Icons.info_outline_rounded
                : _saved
                    ? Icons.check_rounded
                    : Icons.bookmark_add_outlined,
          ),
          label: Text(
            isDemo
                ? l10n.demoSaveDisabled
                : _saved
                    ? l10n.savedToDiary
                    : l10n.saveToDiary,
          ),
        ),
      ),
    );
  }

  Future<void> _editFood(int index) async {
    final food = _foods[index];
    final result = await showModalBottomSheet<_FoodEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditFoodSheet(food: food),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.remove) {
        _foods.removeAt(index);
      } else {
        _foods[index] = food.copyWith(name: result.name, quantity: result.quantity);
      }
    });
  }

  Future<void> _save() async {
    final controller = AppScope.of(context);
    final analysis = MealAnalysis(
      analysisId: widget.initialAnalysis.analysisId,
      calories: _calories,
      protein: _protein,
      carbs: _carbs,
      fat: _fat,
      confidence: widget.initialAnalysis.confidence,
      foods: _foods,
      caveats: widget.initialAnalysis.caveats,
      questions: widget.initialAnalysis.questions,
      provider: widget.initialAnalysis.provider,
    );
    await controller.addDiaryEntry(
      DiaryEntry.fromAnalysis(
        analysis: analysis,
        mealLabel: _mealName?.text.trim().isNotEmpty == true
            ? _mealName!.text.trim()
            : context.l10n.mealNameDefault,
      ),
    );
    _deleteCameraTemp();
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.savedToDiary)),
    );
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _retake() async {
    final controller = AppScope.of(context);
    if (!controller.canScan) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PaywallScreen()),
      );
      return;
    }
    _deleteCameraTemp();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ScanScreen()),
    );
  }

  void _deleteCameraTemp() {
    if (widget.source != 'camera') return;
    try {
      final file = File(widget.imagePath);
      if (file.existsSync()) file.deleteSync();
    } on FileSystemException {
      // Android may already have evicted the cache file.
    }
  }

}

class _RangeCard extends StatelessWidget {
  const _RangeCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final NutrientRange value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 14),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${value.min.round()}–${value.max.round()} $unit',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text('≈ ${value.estimated.round()} $unit'),
            ],
          ),
        ),
      );
}

class _SmallMacro extends StatelessWidget {
  const _SmallMacro({required this.label, required this.value, required this.unit});

  final String label;
  final NutrientRange value;
  final String unit;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '${value.estimated.round()} $unit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.food, required this.onEdit});

  final FoodEstimate food;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: const Icon(Icons.restaurant_menu_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      '${food.quantity.toStringAsFixed(food.quantity % 1 == 0 ? 0 : 1)} ${food.unit} · '
                      '${food.calories.min.round()}–${food.calories.max.round()} ${l10n.kcal} · '
                      '${food.protein.estimated.round()} ${l10n.gramsShort} ${l10n.protein.toLowerCase()}',
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: l10n.editFood,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Caveat extends StatelessWidget {
  const _Caveat({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 19,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 9),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _FoodEditResult {
  const _FoodEditResult({
    required this.name,
    required this.quantity,
    this.remove = false,
  });

  final String name;
  final double quantity;
  final bool remove;
}

class _EditFoodSheet extends StatefulWidget {
  const _EditFoodSheet({required this.food});

  final FoodEstimate food;

  @override
  State<_EditFoodSheet> createState() => _EditFoodSheetState();
}

class _EditFoodSheetState extends State<_EditFoodSheet> {
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  String? _quantityError;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.food.name);
    _quantity = TextEditingController(text: widget.food.quantity.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editFood, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 18),
          TextField(
            controller: _name,
            readOnly: true,
            enableInteractiveSelection: false,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.foodName,
              helperText: l10n.foodNameLocked,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_quantityError != null) setState(() => _quantityError = null);
            },
            decoration: InputDecoration(
              labelText: l10n.portion,
              suffixText: widget.food.unit,
              errorText: _quantityError,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              final quantity = double.tryParse(_quantity.text.replaceAll(',', '.'));
              if (quantity == null ||
                  !quantity.isFinite ||
                  quantity <= 0 ||
                  quantity > 5000) {
                setState(() => _quantityError = l10n.invalidPortion);
                return;
              }
              Navigator.pop(
                context,
                _FoodEditResult(name: _name.text.trim(), quantity: quantity),
              );
            },
            child: Text(l10n.save),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(
              context,
              _FoodEditResult(
                name: widget.food.name,
                quantity: widget.food.quantity,
                remove: true,
              ),
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.removeFood),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }
}
