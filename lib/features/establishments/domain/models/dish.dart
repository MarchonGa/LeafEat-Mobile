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
    this.serverAverageRating,
    this.reviewCount = 0,
    this.recipeComponents = const [],
    this.foodComponents = const [],
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
        serverAverageRating:
            (json['averageRating'] as num?)?.toDouble(),
        reviewCount: (json['reviewCount'] as num? ?? 0).toInt(),
        recipeComponents: (json['recipeComponents'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(DishRecipeComponent.fromJson)
                .toList(growable: false) ??
            const [],
        foodComponents: (json['foodComponents'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(DishFoodComponent.fromJson)
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
  final double? serverAverageRating;
  final int reviewCount;
  final List<DishRecipeComponent> recipeComponents;
  final List<DishFoodComponent> foodComponents;
  final List<Review> reviews;

  static int calculateCalories({
    required double proteinGrams,
    required double carbohydrateGrams,
    required double fatGrams,
  }) {
    return ((proteinGrams * 4) + (carbohydrateGrams * 4) + (fatGrams * 9)).round();
  }

  double get averageRating {
    if (serverAverageRating != null) return serverAverageRating!;
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  int get totalReviews => reviewCount > 0 ? reviewCount : reviews.length;
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

class DishFoodComponent {
  const DishFoodComponent({
    required this.id,
    required this.nutritionalFoodId,
    required this.foodName,
    required this.quantityGrams,
    required this.energyKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.sodiumMilligrams,
    this.preparation,
  });

  final String id;
  final int nutritionalFoodId;
  final String foodName;
  final String? preparation;
  final double quantityGrams;
  final double? energyKcal;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;
  final double? fiberGrams;
  final double? sodiumMilligrams;

  factory DishFoodComponent.fromJson(Map<String, dynamic> json) {
    final values = json['per100Grams'] is Map<String, dynamic>
        ? json['per100Grams'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return DishFoodComponent(
      id: json['id']?.toString() ?? '',
      nutritionalFoodId:
          (json['nutritionalFoodId'] as num?)?.toInt() ?? 0,
      foodName: json['foodName']?.toString() ?? '',
      preparation: json['preparation']?.toString(),
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

