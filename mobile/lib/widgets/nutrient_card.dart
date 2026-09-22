import 'dart:math' as math;

import 'package:flutter/material.dart';

class NutrientCard extends StatelessWidget {
  const NutrientCard({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
    required this.goalText,
    super.key,
  });

  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;
  final String goalText;

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : math.min(value / goal, 1.0);
    final rounded = value.round();
    return Semantics(
      label: '$label, $rounded $unit, $goalText',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      color: color,
                      backgroundColor: color.withValues(alpha: .13),
                    ),
                    Icon(
                      label.toLowerCase().contains('protein')
                          ? Icons.fitness_center_rounded
                          : Icons.local_fire_department_rounded,
                      size: 23,
                      color: color,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$rounded',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextSpan(text: ' $unit'),
                    ],
                  ),
                ),
              ),
              Text(
                goalText,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
