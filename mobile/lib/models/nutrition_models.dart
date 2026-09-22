import 'dart:convert';

class NutrientRange {
  const NutrientRange({
    required this.min,
    required this.max,
    required this.estimated,
  });

  final double min;
  final double max;
  final double estimated;

  factory NutrientRange.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    final estimate = _number(data['estimated'] ?? data['estimate']);
    return NutrientRange(
      min: _number(data['min'], fallback: estimate),
      max: _number(data['max'], fallback: estimate),
      estimated: estimate,
    );
  }

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'estimated': estimated,
      };

  NutrientRange scale(double factor) => NutrientRange(
        min: min * factor,
        max: max * factor,
        estimated: estimated * factor,
      );
}

class FoodEstimate {
  const FoodEstimate({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final NutrientRange calories;
  final NutrientRange protein;
  final NutrientRange carbs;
  final NutrientRange fat;
  final double confidence;

  factory FoodEstimate.fromJson(Map<String, dynamic> json) => FoodEstimate(
        id: (json['id'] ?? json['catalog_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        quantity: _number(json['quantity'], fallback: 1),
        unit: (json['unit'] ?? 'serving').toString(),
        calories: NutrientRange.fromJson(_map(json['calories'])),
        protein: NutrientRange.fromJson(_map(json['protein_g'])),
        carbs: NutrientRange.fromJson(_map(json['carbs_g'])),
        fat: NutrientRange.fromJson(_map(json['fat_g'])),
        confidence: _number(json['confidence'], fallback: .5),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'calories': calories.toJson(),
        'protein_g': protein.toJson(),
        'carbs_g': carbs.toJson(),
        'fat_g': fat.toJson(),
        'confidence': confidence,
      };

  FoodEstimate copyWith({String? name, double? quantity}) {
    final nextQuantity = quantity ?? this.quantity;
    final factor = this.quantity <= 0 ? 1.0 : nextQuantity / this.quantity;
    return FoodEstimate(
      id: id,
      name: name ?? this.name,
      quantity: nextQuantity,
      unit: unit,
      calories: calories.scale(factor),
      protein: protein.scale(factor),
      carbs: carbs.scale(factor),
      fat: fat.scale(factor),
      confidence: confidence,
    );
  }
}

class FollowUpOption {
  const FollowUpOption({required this.id, required this.label});

  final String id;
  final String label;

  factory FollowUpOption.fromJson(Map<String, dynamic> json) => FollowUpOption(
        id: (json['id'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
      );
}

class FollowUpQuestion {
  const FollowUpQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String type;
  final String prompt;
  final List<FollowUpOption> options;

  factory FollowUpQuestion.fromJson(Map<String, dynamic> json) => FollowUpQuestion(
        id: (json['id'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        prompt: (json['prompt'] ?? '').toString(),
        options: _list(json['options'])
            .map((item) => FollowUpOption.fromJson(_map(item) ?? const {}))
            .toList(),
      );
}

class MealAnalysis {
  const MealAnalysis({
    required this.analysisId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.foods,
    required this.caveats,
    required this.questions,
    required this.provider,
  });

  final String analysisId;
  final NutrientRange calories;
  final NutrientRange protein;
  final NutrientRange carbs;
  final NutrientRange fat;
  final double confidence;
  final List<FoodEstimate> foods;
  final List<String> caveats;
  final List<FollowUpQuestion> questions;
  final String provider;

  factory MealAnalysis.fromJson(Map<String, dynamic> json) {
    final total = _map(json['total']) ?? const <String, dynamic>{};
    return MealAnalysis(
      analysisId: (json['analysis_id'] ?? json['request_id'] ?? '').toString(),
      calories: NutrientRange.fromJson(_map(total['calories'])),
      protein: NutrientRange.fromJson(_map(total['protein_g'])),
      carbs: NutrientRange.fromJson(_map(total['carbs_g'])),
      fat: NutrientRange.fromJson(_map(total['fat_g'])),
      confidence: _number(json['confidence'], fallback: .5),
      foods: _list(json['foods'])
          .map((item) => FoodEstimate.fromJson(_map(item) ?? const {}))
          .toList(),
      caveats: _list(json['caveats']).map((item) => item.toString()).toList(),
      questions: _list(json['follow_up_questions'])
          .map((item) => FollowUpQuestion.fromJson(_map(item) ?? const {}))
          .toList(),
      provider: (json['provider'] ?? 'unknown').toString(),
    );
  }
}

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.createdAt,
    required this.mealLabel,
    required this.foods,
    required this.calories,
    required this.protein,
    required this.confidence,
    this.imagePath,
  });

  final String id;
  final DateTime createdAt;
  final String mealLabel;
  final List<FoodEstimate> foods;
  final NutrientRange calories;
  final NutrientRange protein;
  final double confidence;
  final String? imagePath;

  factory DiaryEntry.fromAnalysis({
    required MealAnalysis analysis,
    required String mealLabel,
    String? imagePath,
  }) {
    final now = DateTime.now();
    return DiaryEntry(
      id: analysis.analysisId.isEmpty
          ? '${now.microsecondsSinceEpoch}'
          : analysis.analysisId,
      createdAt: now,
      mealLabel: mealLabel,
      foods: analysis.foods,
      calories: analysis.calories,
      protein: analysis.protein,
      confidence: analysis.confidence,
      imagePath: imagePath,
    );
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: (json['id'] ?? '').toString(),
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        mealLabel: (json['meal_label'] ?? '').toString(),
        foods: _list(json['foods'])
            .map((item) => FoodEstimate.fromJson(_map(item) ?? const {}))
            .toList(),
        calories: NutrientRange.fromJson(_map(json['calories'])),
        protein: NutrientRange.fromJson(_map(json['protein_g'])),
        confidence: _number(json['confidence'], fallback: .5),
        imagePath: json['image_path']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'meal_label': mealLabel,
        'foods': foods.map((food) => food.toJson()).toList(),
        'calories': calories.toJson(),
        'protein_g': protein.toJson(),
        'confidence': confidence,
        'image_path': imagePath,
      };
}

List<DiaryEntry> decodeDiary(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    return _list(jsonDecode(raw))
        .map((item) => DiaryEntry.fromJson(_map(item) ?? const {}))
        .toList();
  } on FormatException {
    return [];
  }
}

String encodeDiary(List<DiaryEntry> entries) =>
    jsonEncode(entries.map((entry) => entry.toJson()).toList());

double _number(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return null;
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];
