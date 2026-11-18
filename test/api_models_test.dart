import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/app/session/user_mode.dart';
import 'package:leafeat_mobile/features/auth/data/auth_user.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_dashboard.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_review.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';
import 'package:leafeat_mobile/features/restaurant/data/nutritional_food.dart';

void main() {
  test('maps review received by restaurant', () {
    final review = RestaurantReview.fromJson({
      'id': 'review-id',
      'customerName': 'Marina',
      'dishId': 'dish-id',
      'dishName': 'Bowl',
      'dishRating': 5,
      'environmentRating': 4,
      'comment': 'Muito bom',
      'createdAt': '2026-11-17T12:00:00Z',
    });

    expect(review.customerName, 'Marina');
    expect(review.dishName, 'Bowl');
    expect(review.averageRating, 4.5);
  });

  test('maps restaurant dashboard returned by API', () {
    final dashboard = RestaurantDashboard.fromJson({
      'establishmentId': 'establishment-id',
      'establishmentName': 'Sabor Natural',
      'totalDishes': 2,
      'dishesWithNutrition': 1,
      'reviewCount': 3,
      'averageRating': 4.46,
      'coveragePercentage': 50.0,
      'badgeLevel': 'Prata',
    });

    expect(dashboard.totalDishes, 2);
    expect(dashboard.dishesWithNutrition, 1);
    expect(dashboard.reviewCount, 3);
    expect(dashboard.averageRating, 4.46);
    expect(dashboard.coveragePercentage, 50);
    expect(dashboard.badgeLevel, 'Prata');
  });

  test('maps restaurant session returned by API', () {
    final user = AuthUser.fromJson({
      'id': 'user-id',
      'name': 'Sabor Natural',
      'email': 'restaurante@leafeat.local',
      'role': 'Restaurant',
      'dietaryRestrictions': <String>[],
      'establishmentId': 'establishment-id',
    });

    expect(user.role, UserMode.restaurant);
    expect(user.establishmentId, 'establishment-id');
  });

  test('maps establishment and dishes returned by API', () {
    final establishment = Establishment.fromJson({
      'id': 'establishment-id',
      'name': 'Sabor Natural',
      'category': 'Saudável',
      'description': 'Refeições equilibradas.',
      'address': 'Centro',
      'distanceKm': 0.8,
      'averageRating': 4.8,
      'badgePercentage': 100.0,
      'dishes': [
        {
          'id': 'dish-id',
          'name': 'Bowl vegano',
          'description': 'Grão-de-bico e legumes.',
          'price': 27.5,
          'calories': 419,
          'proteinGrams': 18.0,
          'carbohydrateGrams': 62.0,
          'fatGrams': 11.0,
          'fiberGrams': 12.0,
          'isVegan': true,
          'isLactoseFree': true,
        }
      ],
    });

    expect(establishment.averageRating, 4.8);
    expect(establishment.dishes.single.name, 'Bowl vegano');
    expect(establishment.badge.label, 'Ouro');
  });

  test('maps a paginated nutritional catalog response', () {
    final page = NutritionalFoodPage.fromJson({
      'page': 1,
      'pageSize': 25,
      'total': 597,
      'totalPages': 24,
      'source': 'TACO',
      'sourceVersion': '4ª edição',
      'items': [
        {
          'id': 1,
          'sourceCode': '1',
          'source': 'TACO',
          'sourceVersion': '4ª edição',
          'description': 'Arroz, integral, cozido',
          'baseName': 'Arroz',
          'preparation': 'cozido',
          'qualifiers': 'integral',
          'category': 'Cereais e derivados',
          'per100Grams': {
            'energyKcal': 128.0,
            'proteinGrams': 2.6,
            'carbohydrateGrams': 25.8,
            'fatGrams': 1.0,
            'fiberGrams': 2.7,
            'sodiumMilligrams': 1.0,
          },
        },
      ],
    });

    expect(page.total, 597);
    expect(page.totalPages, 24);
    expect(page.items.single.description, 'Arroz, integral, cozido');
    expect(page.items.single.preparation, 'cozido');
  });

  test('scales nutrients from 100 grams to the quantity used', () {
    const nutrients = Nutrients(
      energyKcal: 128,
      proteinGrams: 2.6,
      carbohydrateGrams: 25.8,
      fatGrams: 1,
      fiberGrams: 2.7,
    );

    final result = nutrients.scaledTo(130);

    expect(result.energyKcal, closeTo(166.4, 0.0001));
    expect(result.proteinGrams, closeTo(3.38, 0.0001));
    expect(result.carbohydrateGrams, closeTo(33.54, 0.0001));
    expect(result.fatGrams, closeTo(1.3, 0.0001));
    expect(result.fiberGrams, closeTo(3.51, 0.0001));
    expect(result.sodiumMilligrams, isNull);
  });


  test('maps a saved restaurant recipe and its ingredients', () {
    final recipe = RestaurantRecipe.fromJson({
      'id': 'recipe-id',
      'establishmentId': 'establishment-id',
      'name': 'Risoto de cenoura',
      'description': 'Receita base da casa',
      'rawIngredientsWeightGrams': 540.0,
      'finalWeightGrams': 600.0,
      'createdAt': '2026-11-18T12:00:00Z',
      'total': {
        'energyKcal': 503.2,
        'proteinGrams': 11.44,
      },
      'per100Grams': {
        'energyKcal': 83.866,
        'proteinGrams': 1.906,
      },
      'ingredients': [
        {
          'id': 'ingredient-id',
          'nutritionalFoodId': 1,
          'description': 'Arroz, parboilizado, cru',
          'preparation': 'cru',
          'category': 'Cereais e derivados',
          'quantityGrams': 340.0,
          'per100Grams': {'energyKcal': 128.0},
          'contribution': {'energyKcal': 435.2},
        },
      ],
    });

    expect(recipe.name, 'Risoto de cenoura');
    expect(recipe.finalWeightGrams, 600);
    expect(recipe.per100Grams.energyKcal, closeTo(83.866, 0.001));
    expect(recipe.ingredients.single.quantityGrams, 340);
  });

  test('creates the ingredient payload selected from TACO', () {
    final food = NutritionalFood.fromJson({
      'id': 17,
      'sourceCode': '17',
      'source': 'TACO',
      'sourceVersion': '4ª edição',
      'description': 'Arroz, parboilizado, cru',
      'baseName': 'Arroz',
      'preparation': 'cru',
      'category': 'Cereais e derivados',
      'per100Grams': {'energyKcal': 358.0},
    });
    final selection = NutritionalFoodSelection(
      food: food,
      quantityGrams: 340,
    );

    expect(selection.toRequestJson(), {
      'nutritionalFoodId': 17,
      'quantityGrams': 340.0,
    });
  });


  test('maps a house recipe used as a dish component', () {
    final dish = Dish.fromJson({
      'id': 'dish-id',
      'name': 'Prato executivo',
      'description': 'Arroz e acompanhamento',
      'price': 25.0,
      'calories': 311,
      'proteinGrams': 6.04,
      'carbohydrateGrams': 62.42,
      'fatGrams': 3.36,
      'fiberGrams': 2.0,
      'isVegan': false,
      'isLactoseFree': true,
      'hasNutritionInformation': true,
      'recipeComponents': [
        {
          'id': 'component-id',
          'recipeId': 'recipe-id',
          'recipeName': 'Arroz ao alho',
          'quantityGrams': 200.0,
          'per100Grams': {
            'energyKcal': 155.56,
            'proteinGrams': 3.02,
            'carbohydrateGrams': 31.21,
            'fatGrams': 1.68,
            'fiberGrams': 1.0,
          },
          'contribution': {
            'energyKcal': 311.12,
          },
        },
      ],
    });

    expect(dish.recipeComponents.single.recipeName, 'Arroz ao alho');
    expect(dish.recipeComponents.single.quantityGrams, 200);
    expect(dish.recipeComponents.single.fatGrams, 1.68);
  });

  test('creates payload for a recipe portion used in a dish', () {
    const selection = DishRecipeSelection(
      recipeId: 'recipe-id',
      recipeName: 'Arroz ao alho',
      quantityGrams: 200,
      per100Grams: Nutrients(energyKcal: 155.56),
    );

    expect(selection.toRequestJson(), {
      'recipeId': 'recipe-id',
      'quantityGrams': 200.0,
    });
  });

}
