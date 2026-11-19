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
    this.visitId = '',
    this.visitScheduledAt,
    this.visitConfirmedAt,
    this.restaurantResponse,
    this.responseUpdatedAt,
    this.internalNote,
    this.internalNoteUpdatedAt,
  });

  factory RestaurantReview.fromJson(Map<String, dynamic> json) =>
      RestaurantReview(
        id: json['id'] as String,
        customerId: json['customerId']?.toString() ?? '',
        customerName:
            json['customerName'] as String? ?? 'Cliente LeafEat',
        dishId: json['dishId'] as String?,
        dishName: json['dishName'] as String?,
        dishRating: (json['dishRating'] as num).toInt(),
        environmentRating:
            (json['environmentRating'] as num).toInt(),
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        helpfulCount:
            (json['helpfulCount'] as num? ?? 0).toInt(),
        notHelpfulCount:
            (json['notHelpfulCount'] as num? ?? 0).toInt(),
        visitId: json['visitId']?.toString() ?? '',
        visitScheduledAt: DateTime.parse(
          json['visitScheduledAt'] as String,
        ).toLocal(),
        visitConfirmedAt: json['visitConfirmedAt'] == null
            ? null
            : DateTime.parse(
                json['visitConfirmedAt'] as String,
              ).toLocal(),
        restaurantResponse: json['restaurantResponse'] as String?,
        responseUpdatedAt: json['responseUpdatedAt'] == null
            ? null
            : DateTime.parse(
                json['responseUpdatedAt'] as String,
              ).toLocal(),
        internalNote: json['internalNote'] as String?,
        internalNoteUpdatedAt: json['internalNoteUpdatedAt'] == null
            ? null
            : DateTime.parse(
                json['internalNoteUpdatedAt'] as String,
              ).toLocal(),
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
  final String visitId;
  final DateTime? visitScheduledAt;
  final DateTime? visitConfirmedAt;
  final String? restaurantResponse;
  final DateTime? responseUpdatedAt;
  final String? internalNote;
  final DateTime? internalNoteUpdatedAt;

  double get averageRating =>
      (dishRating + environmentRating) / 2;
}
