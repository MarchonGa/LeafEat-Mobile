import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/features/customer/data/customer_visit.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_review.dart';

void main() {
  test('confirmed customer visit enables a review', () {
    final visit = CustomerVisit.fromJson({
      'id': 'visit-1',
      'establishmentId': 'establishment-1',
      'establishmentName': 'Sabor Natural',
      'dishId': 'dish-1',
      'dishName': 'Bowl',
      'confirmationCode': 'LF-123456',
      'status': 'Confirmed',
      'scheduledAt': '2026-11-19T15:00:00Z',
      'confirmedAt': '2026-11-19T15:05:00Z',
      'canReview': true,
    });

    expect(visit.canReview, isTrue);
    expect(visit.statusLabel, 'Presença confirmada');
    expect(visit.confirmationCode, 'LF-123456');
  });

  test('restaurant review separates public response and internal note', () {
    final review = RestaurantReview.fromJson({
      'id': 'review-1',
      'customerId': 'customer-1',
      'customerName': 'G******',
      'dishId': 'dish-1',
      'dishName': 'Bowl',
      'dishRating': 5,
      'environmentRating': 3,
      'comment': 'O prato estava bom.',
      'createdAt': '2026-11-19T15:30:00Z',
      'helpfulCount': 2,
      'notHelpfulCount': 0,
      'visitId': 'visit-1',
      'visitScheduledAt': '2026-11-19T15:00:00Z',
      'visitConfirmedAt': '2026-11-19T15:05:00Z',
      'restaurantResponse': 'Pedimos desculpas pelo atendimento.',
      'responseUpdatedAt': '2026-11-19T16:00:00Z',
      'internalNote': 'Conversar com a equipe do turno.',
      'internalNoteUpdatedAt': '2026-11-19T16:01:00Z',
    });

    expect(review.restaurantResponse, contains('desculpas'));
    expect(review.internalNote, contains('equipe'));
    expect(review.visitConfirmedAt, isNotNull);
  });
}
