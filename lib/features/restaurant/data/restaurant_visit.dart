class RestaurantVisit {
  const RestaurantVisit({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.establishmentId,
    required this.establishmentName,
    required this.dishId,
    required this.dishName,
    required this.confirmationCode,
    required this.status,
    required this.scheduledAt,
    required this.confirmedAt,
    required this.canReview,
  });

  factory RestaurantVisit.fromJson(Map<String, dynamic> json) =>
      RestaurantVisit(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String? ?? 'Cliente LeafEat',
        establishmentId: json['establishmentId'] as String,
        establishmentName:
            json['establishmentName'] as String? ?? 'Estabelecimento',
        dishId: json['dishId'] as String,
        dishName: json['dishName'] as String? ?? 'Prato',
        confirmationCode: json['confirmationCode'] as String,
        status: json['status'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String).toLocal(),
        confirmedAt: json['confirmedAt'] == null
            ? null
            : DateTime.parse(json['confirmedAt'] as String).toLocal(),
        canReview: json['canReview'] as bool? ?? false,
      );

  final String id;
  final String customerId;
  final String customerName;
  final String establishmentId;
  final String establishmentName;
  final String dishId;
  final String dishName;
  final String confirmationCode;
  final String status;
  final DateTime scheduledAt;
  final DateTime? confirmedAt;
  final bool canReview;
}
