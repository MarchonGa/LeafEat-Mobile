class RestaurantReview {
  const RestaurantReview({
    required this.id,
    required this.customerName,
    required this.dishId,
    required this.dishName,
    required this.dishRating,
    required this.environmentRating,
    required this.comment,
    required this.createdAt,
  });

  factory RestaurantReview.fromJson(Map<String, dynamic> json) =>
      RestaurantReview(
        id: json['id'] as String,
        customerName: json['customerName'] as String,
        dishId: json['dishId'] as String?,
        dishName: json['dishName'] as String?,
        dishRating: (json['dishRating'] as num).toInt(),
        environmentRating:
            (json['environmentRating'] as num).toInt(),
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String customerName;
  final String? dishId;
  final String? dishName;
  final int dishRating;
  final int environmentRating;
  final String comment;
  final DateTime createdAt;

  double get averageRating =>
      (dishRating + environmentRating) / 2;
}
