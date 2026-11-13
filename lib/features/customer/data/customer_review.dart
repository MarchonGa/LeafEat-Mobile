class CustomerReview {
  const CustomerReview({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    required this.dishName,
    required this.dishRating,
    required this.environmentRating,
    required this.comment,
    required this.createdAt,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
        id: json['id'] as String,
        establishmentId: json['establishmentId'] as String,
        establishmentName: json['establishmentName'] as String,
        dishName: json['dishName'] as String?,
        dishRating: json['dishRating'] as int,
        environmentRating: json['environmentRating'] as int,
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String establishmentId;
  final String establishmentName;
  final String? dishName;
  final int dishRating;
  final int environmentRating;
  final String comment;
  final DateTime createdAt;

  double get averageRating => (dishRating + environmentRating) / 2;
}
