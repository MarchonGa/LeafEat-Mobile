class RestaurantDashboard {
  const RestaurantDashboard({
    required this.establishmentId,
    required this.establishmentName,
    required this.totalDishes,
    required this.dishesWithNutrition,
    required this.reviewCount,
    required this.averageRating,
    required this.coveragePercentage,
    required this.badgeLevel,
  });

  factory RestaurantDashboard.fromJson(Map<String, dynamic> json) =>
      RestaurantDashboard(
        establishmentId: json['establishmentId'] as String,
        establishmentName: json['establishmentName'] as String,
        totalDishes: (json['totalDishes'] as num).toInt(),
        dishesWithNutrition:
            (json['dishesWithNutrition'] as num).toInt(),
        reviewCount: (json['reviewCount'] as num).toInt(),
        averageRating: (json['averageRating'] as num).toDouble(),
        coveragePercentage:
            (json['coveragePercentage'] as num).toDouble(),
        badgeLevel: json['badgeLevel'] as String?,
      );

  final String establishmentId;
  final String establishmentName;
  final int totalDishes;
  final int dishesWithNutrition;
  final int reviewCount;
  final double averageRating;
  final double coveragePercentage;
  final String? badgeLevel;
}
