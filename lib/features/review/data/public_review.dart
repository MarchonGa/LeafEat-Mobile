class PublicReview {
  const PublicReview({
    required this.id,
    required this.authorId,
    required this.authorDisplayName,
    required this.establishmentId,
    required this.dishId,
    required this.dishName,
    required this.dishRating,
    required this.environmentRating,
    required this.comment,
    required this.createdAt,
    required this.helpfulCount,
    required this.notHelpfulCount,
    required this.currentUserVote,
    required this.isOwnReview,
    this.presenceConfirmed = false,
    this.restaurantResponse,
    this.responseUpdatedAt,
  });

  factory PublicReview.fromJson(Map<String, dynamic> json) =>
      PublicReview(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        authorDisplayName:
            json['authorDisplayName'] as String? ?? 'Cliente LeafEat',
        establishmentId: json['establishmentId'] as String,
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
        currentUserVote:
            (json['currentUserVote'] as num?)?.toInt(),
        isOwnReview: json['isOwnReview'] as bool? ?? false,
        presenceConfirmed: json['presenceConfirmed'] as bool? ?? false,
        restaurantResponse: json['restaurantResponse'] as String?,
        responseUpdatedAt: json['responseUpdatedAt'] == null
            ? null
            : DateTime.parse(json['responseUpdatedAt'] as String).toLocal(),
      );

  final String id;
  final String authorId;
  final String authorDisplayName;
  final String establishmentId;
  final String? dishId;
  final String? dishName;
  final int dishRating;
  final int environmentRating;
  final String comment;
  final DateTime createdAt;
  final int helpfulCount;
  final int notHelpfulCount;
  final int? currentUserVote;
  final bool isOwnReview;
  final bool presenceConfirmed;
  final String? restaurantResponse;
  final DateTime? responseUpdatedAt;

  double get averageRating =>
      (dishRating + environmentRating) / 2;

  PublicReview withVoteSummary(Map<String, dynamic> json) =>
      PublicReview(
        id: id,
        authorId: authorId,
        authorDisplayName: authorDisplayName,
        establishmentId: establishmentId,
        dishId: dishId,
        dishName: dishName,
        dishRating: dishRating,
        environmentRating: environmentRating,
        comment: comment,
        createdAt: createdAt,
        helpfulCount:
            (json['helpfulCount'] as num? ?? helpfulCount).toInt(),
        notHelpfulCount:
            (json['notHelpfulCount'] as num? ??
                    notHelpfulCount)
                .toInt(),
        currentUserVote:
            (json['currentUserVote'] as num?)?.toInt(),
        isOwnReview: isOwnReview,
        presenceConfirmed: presenceConfirmed,
        restaurantResponse: restaurantResponse,
        responseUpdatedAt: responseUpdatedAt,
      );
}

class PublicCustomerProfile {
  const PublicCustomerProfile({
    required this.userId,
    required this.displayName,
    required this.dietaryPreferences,
  });

  factory PublicCustomerProfile.fromJson(
    Map<String, dynamic> json,
  ) =>
      PublicCustomerProfile(
        userId: json['userId'] as String,
        displayName:
            json['displayName'] as String? ?? 'Cliente LeafEat',
        dietaryPreferences:
            (json['dietaryPreferences'] as List<dynamic>? ??
                    const [])
                .map((item) => item.toString())
                .toList(),
      );

  final String userId;
  final String displayName;
  final List<String> dietaryPreferences;
}
