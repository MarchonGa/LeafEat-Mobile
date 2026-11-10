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
    this.serverAverageRating,
    this.reviews = const [],
  });

  factory Establishment.fromJson(Map<String, dynamic> json) => Establishment(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        address: json['address'] as String,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        badgePercentage: (json['badgePercentage'] as num).toDouble(),
        serverAverageRating: (json['averageRating'] as num?)?.toDouble(),
        dishes: (json['dishes'] as List<dynamic>? ?? const [])
            .map((item) => Dish.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String name;
  final String category;
  final String description;
  final String address;
  final double distanceKm;
  final double badgePercentage;
  final List<Dish> dishes;
  final List<Review> reviews;
  final double? serverAverageRating;

  Badge get badge => Badge.fromPercentage(badgePercentage);

  double get averageRating {
    if (serverAverageRating != null) return serverAverageRating!;
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}
