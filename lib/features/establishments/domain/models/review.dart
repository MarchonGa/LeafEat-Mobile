class Review {
  const Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  }) : assert(rating >= 0 && rating <= 5);

  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime createdAt;
}
