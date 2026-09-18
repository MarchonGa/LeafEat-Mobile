import 'package:leafeat_mobile/features/establishments/domain/models/badge.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/review.dart';

class Establishment {
  const Establishment({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.distanceKm,
    required this.badgePercentage,
    required this.dishes,
    this.reviews = const [],
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String address;
  final double distanceKm;
  final double badgePercentage;
  final List<Dish> dishes;
  final List<Review> reviews;

  Badge get badge => Badge.fromPercentage(badgePercentage);

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}
