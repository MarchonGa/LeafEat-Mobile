import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';
import 'package:leafeat_mobile/features/review/data/public_review.dart';

void main() {
  test('maps public review vote summary', () {
    final review = PublicReview.fromJson({
      'id': 'review-1',
      'authorId': 'user-1',
      'authorDisplayName': 'G******',
      'establishmentId': 'establishment-1',
      'dishId': null,
      'dishName': null,
      'dishRating': 4,
      'environmentRating': 5,
      'comment': 'Boa experiência',
      'createdAt': '2026-11-18T12:00:00Z',
      'helpfulCount': 3,
      'notHelpfulCount': 1,
      'currentUserVote': 1,
      'isOwnReview': false,
    });

    expect(review.authorDisplayName, 'G******');
    expect(review.helpfulCount, 3);
    expect(review.currentUserVote, 1);
    expect(review.averageRating, 4.5);
  });

  test('maps a custom item informed by label', () {
    final item = RestaurantRecipe.fromJson({
      'id': 'item-1',
      'establishmentId': 'establishment-1',
      'name': 'Mel',
      'description': 'Produto embalado',
      'calculationMode': 'Label',
      'rawIngredientsWeightGrams': 0,
      'finalWeightGrams': 20,
      'referenceServingGrams': 20,
      'createdAt': '2026-11-18T12:00:00Z',
      'total': {
        'energyKcal': 64,
        'carbohydrateGrams': 17,
      },
      'per100Grams': {
        'energyKcal': 320,
        'carbohydrateGrams': 85,
      },
      'ingredients': <dynamic>[],
    });

    expect(item.isLabel, isTrue);
    expect(item.referenceServingGrams, 20);
    expect(item.per100Grams.energyKcal, 320);
    expect(item.ingredients, isEmpty);
  });
}
