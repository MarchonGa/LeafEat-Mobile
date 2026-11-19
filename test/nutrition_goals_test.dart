import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_goals.dart';

void main() {
  test('parses configured nutrition goals', () {
    final goals = NutritionGoals.fromJson({
      'isConfigured': true,
      'calories': 2000,
      'proteinGrams': 110,
      'carbohydrateGrams': 240,
      'fatGrams': 65,
      'fiberGrams': 25,
    });

    expect(goals.isConfigured, isTrue);
    expect(goals.calories, 2000);
    expect(goals.proteinGrams, 110);
  });

  test('represents the choice not to provide goals', () {
    final goals = NutritionGoals.fromJson({
      'isConfigured': false,
      'calories': null,
      'proteinGrams': null,
      'carbohydrateGrams': null,
      'fatGrams': null,
      'fiberGrams': null,
    });

    expect(goals.isConfigured, isFalse);
    expect(goals.toJson()['calories'], isNull);
  });
}
