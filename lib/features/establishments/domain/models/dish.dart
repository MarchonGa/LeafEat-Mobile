import 'package:leafeat_mobile/features/establishments/domain/models/review.dart';

class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.isVegan,
    required this.isLactoseFree,
    this.hasNutritionInformation = true,
    this.recipeComponents = const [],
    this.reviews = const [],
  });

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        calories: (json['calories'] as num).toInt(),
        proteinGrams: (json['proteinGrams'] as num).toDouble(),
        carbohydrateGrams: (json['carbohydrateGrams'] as num).toDouble(),
        fatGrams: (json['fatGrams'] as num).toDouble(),
        fiberGrams: (json['fiberGrams'] as num).toDouble(),
        isVegan: json['isVegan'] as bool,
        isLactoseFree: json['isLactoseFree'] as bool,
        hasNutritionInformation:
            json['hasNutritionInformation'] as bool? ?? true,
        recipeComponents: (json['recipeComponents'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(DishRecipeComponent.fromJson)
                .toList(growable: false) ??
            const [],
      );

  final String id;
  final String name;
  final String description;
  final double price;
  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final bool isVegan;
  final bool isLactoseFree;
  final bool hasNutritionInformation;
  final List<DishRecipeComponent> recipeComponents;
  final List<Review> reviews;

  static int calculateCalories({
    required double proteinGrams,
    required double carbohydrateGrams,
    required double fatGrams,
  }) {
    return ((proteinGrams * 4) + (carbohydrateGrams * 4) + (fatGrams * 9)).round();
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}


class DishRecipeComponent {
  const DishRecipeComponent({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.quantityGrams,
    required this.energyKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.sodiumMilligrams,
  });

  final String id;
  final String recipeId;
  final String recipeName;
  final double quantityGrams;
  final double? energyKcal;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;
  final double? fiberGrams;
  final double? sodiumMilligrams;

  factory DishRecipeComponent.fromJson(Map<String, dynamic> json) {
    final values = json['per100Grams'] is Map<String, dynamic>
        ? json['per100Grams'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return DishRecipeComponent(
      id: json['id']?.toString() ?? '',
      recipeId: json['recipeId']?.toString() ?? '',
      recipeName: json['recipeName']?.toString() ?? '',
      quantityGrams:
          (json['quantityGrams'] as num?)?.toDouble() ?? 0,
      energyKcal: (values['energyKcal'] as num?)?.toDouble(),
      proteinGrams: (values['proteinGrams'] as num?)?.toDouble(),
      carbohydrateGrams:
          (values['carbohydrateGrams'] as num?)?.toDouble(),
      fatGrams: (values['fatGrams'] as num?)?.toDouble(),
      fiberGrams: (values['fiberGrams'] as num?)?.toDouble(),
      sodiumMilligrams:
          (values['sodiumMilligrams'] as num?)?.toDouble(),
    );
  }
}
