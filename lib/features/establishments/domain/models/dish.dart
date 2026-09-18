import 'package:leafeat_mobile/features/establishments/domain/models/review.dart';

class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.isVegan,
    required this.isLactoseFree,
    this.reviews = const [],
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final int calories;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double fiberGrams;
  final bool isVegan;
  final bool isLactoseFree;
  final List<Review> reviews;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}
