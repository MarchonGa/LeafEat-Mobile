class Nutrients {
  const Nutrients({
    this.energyKcal,
    this.proteinGrams,
    this.carbohydrateGrams,
    this.fatGrams,
    this.fiberGrams,
    this.sodiumMilligrams,
  });

  final double? energyKcal;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;
  final double? fiberGrams;
  final double? sodiumMilligrams;

  factory Nutrients.fromJson(Map<String, dynamic> json) => Nutrients(
        energyKcal: _asDouble(json['energyKcal']),
        proteinGrams: _asDouble(json['proteinGrams']),
        carbohydrateGrams: _asDouble(json['carbohydrateGrams']),
        fatGrams: _asDouble(json['fatGrams']),
        fiberGrams: _asDouble(json['fiberGrams']),
        sodiumMilligrams: _asDouble(json['sodiumMilligrams']),
      );

  Nutrients scaledTo(double grams) {
    final factor = grams / 100;
    return Nutrients(
      energyKcal: _scale(energyKcal, factor),
      proteinGrams: _scale(proteinGrams, factor),
      carbohydrateGrams: _scale(carbohydrateGrams, factor),
      fatGrams: _scale(fatGrams, factor),
      fiberGrams: _scale(fiberGrams, factor),
      sodiumMilligrams: _scale(sodiumMilligrams, factor),
    );
  }

  static double? _scale(double? value, double factor) =>
      value == null ? null : value * factor;
}

class NutritionalFood {
  const NutritionalFood({
    required this.id,
    required this.sourceCode,
    required this.source,
    required this.sourceVersion,
    required this.description,
    required this.baseName,
    required this.category,
    required this.per100Grams,
    this.preparation,
    this.qualifiers,
  });

  final int id;
  final String sourceCode;
  final String source;
  final String sourceVersion;
  final String description;
  final String baseName;
  final String? preparation;
  final String? qualifiers;
  final String category;
  final Nutrients per100Grams;

  factory NutritionalFood.fromJson(Map<String, dynamic> json) {
    final nutrients = json['per100Grams'];
    return NutritionalFood(
      id: (json['id'] as num).toInt(),
      sourceCode: json['sourceCode']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceVersion: json['sourceVersion']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      baseName: json['baseName']?.toString() ?? '',
      preparation: _nullableText(json['preparation']),
      qualifiers: _nullableText(json['qualifiers']),
      category: json['category']?.toString() ?? '',
      per100Grams: Nutrients.fromJson(
        nutrients is Map<String, dynamic> ? nutrients : const {},
      ),
    );
  }
}

class NutritionalFoodPage {
  const NutritionalFoodPage({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.source,
    required this.sourceVersion,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final String source;
  final String sourceVersion;
  final List<NutritionalFood> items;

  factory NutritionalFoodPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return NutritionalFoodPage(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 25,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      source: json['source']?.toString() ?? '',
      sourceVersion: json['sourceVersion']?.toString() ?? '',
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(NutritionalFood.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
