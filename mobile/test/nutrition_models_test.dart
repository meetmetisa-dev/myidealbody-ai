import 'package:flutter_test/flutter_test.dart';
import 'package:myidealbody_ai/models/nutrition_models.dart';

void main() {
  group('MealAnalysis', () {
    test('parses the backend contract and nutrition ranges', () {
      final analysis = MealAnalysis.fromJson({
        'analysis_id': 'meal-1',
        'total': {
          'calories': {'min': 420, 'max': 560, 'estimated': 490},
          'protein_g': {'min': 24, 'max': 34, 'estimated': 29},
          'carbs_g': {'min': 50, 'max': 70, 'estimated': 60},
          'fat_g': {'min': 12, 'max': 20, 'estimated': 16},
        },
        'confidence': .78,
        'foods': [
          {
            'id': 'nasi-putih',
            'name': 'Nasi putih',
            'quantity': 1,
            'unit': 'porsi',
            'calories': {'min': 180, 'max': 240, 'estimated': 210},
            'protein_g': {'min': 3, 'max': 5, 'estimated': 4},
            'carbs_g': {'min': 40, 'max': 52, 'estimated': 46},
            'fat_g': {'min': 0, 'max': 1, 'estimated': .5},
            'confidence': .9,
          },
        ],
        'caveats': ['Hidden oil may change the estimate.'],
        'follow_up_questions': [],
        'provider': 'mock',
      });

      expect(analysis.analysisId, 'meal-1');
      expect(analysis.calories.estimated, 490);
      expect(analysis.protein.min, 24);
      expect(analysis.foods.single.name, 'Nasi putih');
    });

    test('scales a food when its portion changes', () {
      const food = FoodEstimate(
        id: 'tempe',
        name: 'Tempe',
        quantity: 1,
        unit: 'porsi',
        calories: NutrientRange(min: 140, max: 180, estimated: 160),
        protein: NutrientRange(min: 12, max: 16, estimated: 14),
        carbs: NutrientRange(min: 8, max: 12, estimated: 10),
        fat: NutrientRange(min: 7, max: 11, estimated: 9),
        confidence: .8,
      );

      final doubled = food.copyWith(quantity: 2);
      expect(doubled.calories.estimated, 320);
      expect(doubled.protein.min, 24);
    });
  });

  test('diary JSON round-trips without losing entries', () {
    final entry = DiaryEntry(
      id: 'entry-1',
      createdAt: DateTime.utc(2026, 9, 19, 12),
      mealLabel: 'Lunch',
      foods: const [],
      calories: const NutrientRange(min: 400, max: 500, estimated: 450),
      protein: const NutrientRange(min: 20, max: 30, estimated: 25),
      confidence: .7,
    );

    final decoded = decodeDiary(encodeDiary([entry]));
    expect(decoded, hasLength(1));
    expect(decoded.single.mealLabel, 'Lunch');
    expect(decoded.single.createdAt, entry.createdAt);
  });
}

