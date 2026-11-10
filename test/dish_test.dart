import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';

void main() {
  test('calculates calories from macronutrients', () {
    final calories = Dish.calculateCalories(
      proteinGrams: 30,
      carbohydrateGrams: 50,
      fatGrams: 10,
    );

    expect(calories, 410);
  });

  test('rounds fractional calorie totals to the nearest integer', () {
    final calories = Dish.calculateCalories(
      proteinGrams: 10.2,
      carbohydrateGrams: 20.1,
      fatGrams: 5.3,
    );

    expect(calories, 169);
  });
}
