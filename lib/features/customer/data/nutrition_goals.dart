class NutritionGoals {
  const NutritionGoals({
    this.calories,
    this.proteinGrams,
    this.carbohydrateGrams,
    this.fatGrams,
    this.fiberGrams,
  });

  factory NutritionGoals.fromJson(Map<String, dynamic> json) => NutritionGoals(
        calories: (json['calories'] as num?)?.toDouble(),
        proteinGrams: (json['proteinGrams'] as num?)?.toDouble(),
        carbohydrateGrams: (json['carbohydrateGrams'] as num?)?.toDouble(),
        fatGrams: (json['fatGrams'] as num?)?.toDouble(),
        fiberGrams: (json['fiberGrams'] as num?)?.toDouble(),
      );

  final double? calories;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;
  final double? fiberGrams;

  bool get isConfigured => calories != null;

  Map<String, dynamic> toJson() => {
        'calories': calories?.round(),
        'proteinGrams': proteinGrams,
        'carbohydrateGrams': carbohydrateGrams,
        'fatGrams': fatGrams,
        'fiberGrams': fiberGrams,
      };
}
