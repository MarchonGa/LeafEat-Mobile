class CustomerVisit {
  const CustomerVisit({
    required this.id,
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

  factory CustomerVisit.fromJson(Map<String, dynamic> json) => CustomerVisit(
        id: json['id'] as String,
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
  final String establishmentId;
  final String establishmentName;
  final String dishId;
  final String dishName;
  final String confirmationCode;
  final String status;
  final DateTime scheduledAt;
  final DateTime? confirmedAt;
  final bool canReview;

  String get statusLabel => switch (status) {
        'Scheduled' => 'Aguardando comparecimento',
        'Confirmed' => 'Presença confirmada',
        'Evaluated' => 'Avaliação enviada',
        'Cancelled' => 'Cancelada',
        'NoShow' => 'Não compareceu',
        _ => status,
      };
}
