import 'package:leafeat_mobile/features/restaurant/data/nutritional_food.dart';

class NutritionalFoodSelection {
  const NutritionalFoodSelection({
    required this.food,
    required this.quantityGrams,
  });

  final NutritionalFood food;
  final double quantityGrams;

  Map<String, dynamic> toRequestJson() => {
        'nutritionalFoodId': food.id,
        'quantityGrams': quantityGrams,
      };

  NutritionalFoodSelection copyWith({double? quantityGrams}) =>
      NutritionalFoodSelection(
        food: food,
        quantityGrams: quantityGrams ?? this.quantityGrams,
      );
}

class RestaurantRecipe {
  const RestaurantRecipe({
    required this.id,
    required this.establishmentId,
    required this.name,
    required this.description,
    required this.rawIngredientsWeightGrams,
    required this.finalWeightGrams,
    required this.createdAt,
    required this.total,
    required this.per100Grams,
    required this.ingredients,
  });

  final String id;
  final String establishmentId;
  final String name;
  final String description;
  final double rawIngredientsWeightGrams;
  final double finalWeightGrams;
  final DateTime createdAt;
  final Nutrients total;
  final Nutrients per100Grams;
  final List<RecipeIngredient> ingredients;

  factory RestaurantRecipe.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    return RestaurantRecipe(
      id: json['id']?.toString() ?? '',
      establishmentId: json['establishmentId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rawIngredientsWeightGrams:
          (json['rawIngredientsWeightGrams'] as num?)?.toDouble() ?? 0,
      finalWeightGrams:
          (json['finalWeightGrams'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      total: Nutrients.fromJson(
        json['total'] is Map<String, dynamic>
            ? json['total'] as Map<String, dynamic>
            : const {},
      ),
      per100Grams: Nutrients.fromJson(
        json['per100Grams'] is Map<String, dynamic>
            ? json['per100Grams'] as Map<String, dynamic>
            : const {},
      ),
      ingredients: rawIngredients is List
          ? rawIngredients
              .whereType<Map<String, dynamic>>()
              .map(RecipeIngredient.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.id,
    required this.nutritionalFoodId,
    required this.description,
    required this.category,
    required this.quantityGrams,
    required this.per100Grams,
    required this.contribution,
    this.preparation,
  });

  final String id;
  final int nutritionalFoodId;
  final String description;
  final String? preparation;
  final String category;
  final double quantityGrams;
  final Nutrients per100Grams;
  final Nutrients contribution;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        id: json['id']?.toString() ?? '',
        nutritionalFoodId:
            (json['nutritionalFoodId'] as num?)?.toInt() ?? 0,
        description: json['description']?.toString() ?? '',
        preparation: json['preparation']?.toString(),
        category: json['category']?.toString() ?? '',
        quantityGrams:
            (json['quantityGrams'] as num?)?.toDouble() ?? 0,
        per100Grams: Nutrients.fromJson(
          json['per100Grams'] is Map<String, dynamic>
              ? json['per100Grams'] as Map<String, dynamic>
              : const {},
        ),
        contribution: Nutrients.fromJson(
          json['contribution'] is Map<String, dynamic>
              ? json['contribution'] as Map<String, dynamic>
              : const {},
        ),
      );
}

class DishRecipeSelection {
  const DishRecipeSelection({
    required this.recipeId,
    required this.recipeName,
    required this.quantityGrams,
    required this.per100Grams,
  });

  final String recipeId;
  final String recipeName;
  final double quantityGrams;
  final Nutrients per100Grams;

  factory DishRecipeSelection.fromRecipe(
    RestaurantRecipe recipe,
    double quantityGrams,
  ) =>
      DishRecipeSelection(
        recipeId: recipe.id,
        recipeName: recipe.name,
        quantityGrams: quantityGrams,
        per100Grams: recipe.per100Grams,
      );

  DishRecipeSelection copyWith({double? quantityGrams}) =>
      DishRecipeSelection(
        recipeId: recipeId,
        recipeName: recipeName,
        quantityGrams: quantityGrams ?? this.quantityGrams,
        per100Grams: per100Grams,
      );

  Map<String, dynamic> toRequestJson() => {
        'recipeId': recipeId,
        'quantityGrams': quantityGrams,
      };
}

