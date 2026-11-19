import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/customer/data/customer_review.dart';
import 'package:leafeat_mobile/features/customer/data/food_preferences.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_entry.dart';

void main() {
  test('parses and serializes food preferences', () {
    final preferences = FoodPreferences.fromJson({
      'vegan': true,
      'lactoseFree': false,
      'metricMenus': true,
      'dietaryRestrictions': ['Camarão', 'Alimentos amarelos'],
    });

    expect(preferences.vegan, isTrue);
    expect(preferences.lactoseFree, isFalse);
    expect(preferences.metricMenus, isTrue);
    expect(preferences.dietaryRestrictions,
        ['Camarão', 'Alimentos amarelos']);
    expect(preferences.toJson(), {
      'vegan': true,
      'lactoseFree': false,
      'metricMenus': true,
      'dietaryRestrictions': ['Camarão', 'Alimentos amarelos'],
    });
  });

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
      'helpfulCount': 3,
      'notHelpfulCount': 1,
      'restaurantResponse': 'Obrigado pela avaliação.',
    });

    expect(review.averageRating, 4.5);
    expect(review.establishmentName, 'Sabor Natural');
    expect(review.helpfulCount, 3);
    expect(review.notHelpfulCount, 1);
    expect(review.restaurantResponse, 'Obrigado pela avaliação.');
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
    expect(day.fibers, 11);
  });
}
