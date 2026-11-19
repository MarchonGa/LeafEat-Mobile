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
    required this.visitId,
    required this.presenceConfirmed,
    required this.restaurantResponse,
    required this.responseUpdatedAt,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
        id: json['id'] as String,
        establishmentId: json['establishmentId'] as String,
        establishmentName: json['establishmentName'] as String,
        dishName: json['dishName'] as String?,
        dishRating: json['dishRating'] as int,
        environmentRating: json['environmentRating'] as int,
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        visitId: json['visitId']?.toString() ?? '',
        presenceConfirmed: json['presenceConfirmed'] as bool? ?? false,
        restaurantResponse: json['restaurantResponse'] as String?,
        responseUpdatedAt: json['responseUpdatedAt'] == null
            ? null
            : DateTime.parse(json['responseUpdatedAt'] as String).toLocal(),
      );

  final String id;
  final String establishmentId;
  final String establishmentName;
  final String? dishName;
  final int dishRating;
  final int environmentRating;
  final String comment;
  final DateTime createdAt;
  final String visitId;
  final bool presenceConfirmed;
  final String? restaurantResponse;
  final DateTime? responseUpdatedAt;

  double get averageRating => (dishRating + environmentRating) / 2;
}
