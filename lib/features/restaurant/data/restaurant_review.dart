class RestaurantReview {
  const RestaurantReview({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.dishId,
    required this.dishName,
    required this.dishRating,
    required this.environmentRating,
    required this.comment,
    required this.createdAt,
    required this.helpfulCount,
    required this.notHelpfulCount,
  });

  factory RestaurantReview.fromJson(
    Map<String, dynamic> json,
  ) =>
      RestaurantReview(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        customerName:
            json['customerName'] as String? ?? 'Cliente LeafEat',
        dishId: json['dishId'] as String?,
        dishName: json['dishName'] as String?,
        dishRating: (json['dishRating'] as num).toInt(),
        environmentRating:
            (json['environmentRating'] as num).toInt(),
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        helpfulCount:
            (json['helpfulCount'] as num? ?? 0).toInt(),
        notHelpfulCount:
            (json['notHelpfulCount'] as num? ?? 0).toInt(),
      );

  final String id;
  final String customerId;
  final String customerName;
  final String? dishId;
  final String? dishName;
  final int dishRating;
  final int environmentRating;
  final String comment;
  final DateTime createdAt;
  final int helpfulCount;
  final int notHelpfulCount;

  double get averageRating =>
      (dishRating + environmentRating) / 2;
}
