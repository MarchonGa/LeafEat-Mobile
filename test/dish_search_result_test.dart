import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/establishments/data/dish_search_result.dart';

void main() {
  test('parses an exact nutrition search result', () {
    final result = DishSearchResult.fromJson({
      'establishment': {
        'id': 'establishment-1',
        'name': 'Restaurante Verde',
        'description': 'Comida equilibrada',
        'category': 'Saudável',
        'address': 'Rua Principal, 10',
        'distanceKm': 1.2,
        'averageRating': 4.5,
        'badgePercentage': 100,
        'badgeLevel': 'Ouro',
      },
      'dish': {
        'id': 'dish-1',
        'establishmentId': 'establishment-1',
        'name': 'Bowl proteico',
        'description': 'Frango, arroz e legumes',
        'price': 29.9,
        'calories': 410,
        'proteinGrams': 30,
        'carbohydrateGrams': 50,
        'fatGrams': 10,
        'fiberGrams': 8,
        'isVegan': false,
        'isLactoseFree': true,
        'hasNutritionInformation': true,
        'averageRating': 4.8,
        'reviewCount': 5,
        'recipeComponents': <dynamic>[],
        'foodComponents': <dynamic>[],
      },
      'matchScore': 0,
      'isExactMatch': true,
    });

    expect(result.isExactMatch, isTrue);
    expect(result.matchScore, 0);
    expect(result.establishment.name, 'Restaurante Verde');
    expect(result.establishment.dishes, hasLength(1));
    expect(result.dish.proteinGrams, 30);
  });
}
