import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/customer/data/customer_review.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_entry.dart';

void main() {
  test('parses a persisted customer review', () {
    final review = CustomerReview.fromJson({
      'id': 'review-1',
      'establishmentId': 'establishment-1',
      'establishmentName': 'Sabor Natural',
      'dishName': 'Bowl',
      'dishRating': 5,
      'environmentRating': 4,
      'comment': 'Muito bom',
      'createdAt': '2026-11-13T12:00:00Z',
    });

    expect(review.averageRating, 4.5);
    expect(review.establishmentName, 'Sabor Natural');
  });

  test('sums the daily nutrition entries', () {
    final day = NutritionDay.fromJson({
      'entries': [
        {
          'id': 'meal-1',
          'name': 'Marmita externa',
          'consumedAt': '2026-11-13T12:00:00Z',
          'calories': 500,
          'proteinGrams': 30,
          'carbohydrateGrams': 60,
          'fatGrams': 15,
          'fiberGrams': 8,
          'isExternal': true,
        },
        {
          'id': 'meal-2',
          'name': 'Lanche',
          'consumedAt': '2026-11-13T15:00:00Z',
          'calories': 250,
          'proteinGrams': 10,
          'carbohydrateGrams': 35,
          'fatGrams': 8,
          'fiberGrams': 3,
          'isExternal': true,
        },
      ],
    });

    expect(day.calories, 750);
    expect(day.proteins, 40);
    expect(day.carbohydrates, 95);
    expect(day.fats, 23);
  });
}
