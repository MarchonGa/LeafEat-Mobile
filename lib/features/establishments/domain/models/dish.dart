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

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        calories: (json['calories'] as num).toInt(),
        proteinGrams: (json['proteinGrams'] as num).toDouble(),
        carbohydrateGrams: (json['carbohydrateGrams'] as num).toDouble(),
        fatGrams: (json['fatGrams'] as num).toDouble(),
        fiberGrams: (json['fiberGrams'] as num).toDouble(),
        isVegan: json['isVegan'] as bool,
        isLactoseFree: json['isLactoseFree'] as bool,
      );

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

  static int calculateCalories({
    required double proteinGrams,
    required double carbohydrateGrams,
    required double fatGrams,
  }) {
    return ((proteinGrams * 4) + (carbohydrateGrams * 4) + (fatGrams * 9)).round();
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}
