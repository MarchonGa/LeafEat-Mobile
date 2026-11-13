class NutritionEntry {
  const NutritionEntry({
    required this.id,
    required this.name,
    required this.consumedAt,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.isExternal,
  });

  factory NutritionEntry.fromJson(Map<String, dynamic> json) => NutritionEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        consumedAt: DateTime.parse(json['consumedAt'] as String),
        calories: (json['calories'] as num).toDouble(),
        proteinGrams: (json['proteinGrams'] as num).toDouble(),
        carbohydrateGrams: (json['carbohydrateGrams'] as num).toDouble(),
        fatGrams: (json['fatGrams'] as num).toDouble(),
        fiberGrams: (json['fiberGrams'] as num).toDouble(),
        isExternal: json['isExternal'] as bool,
      );

  final String id;
  final String name;
  final DateTime consumedAt;
  final double calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final bool isExternal;
}

class NutritionDay {
  const NutritionDay({required this.entries});

  factory NutritionDay.fromJson(Map<String, dynamic> json) => NutritionDay(
        entries: (json['entries'] as List<dynamic>)
            .map((item) => NutritionEntry.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  final List<NutritionEntry> entries;
  double get calories => entries.fold(0, (sum, item) => sum + item.calories);
  double get proteins => entries.fold(0, (sum, item) => sum + item.proteinGrams);
  double get carbohydrates => entries.fold(0, (sum, item) => sum + item.carbohydrateGrams);
  double get fats => entries.fold(0, (sum, item) => sum + item.fatGrams);
}
