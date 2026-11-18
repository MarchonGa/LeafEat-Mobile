import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/review/data/public_review.dart';

class ReviewRepository {
  const ReviewRepository(this._api);

  final ApiClient _api;

  Future<List<PublicReview>> publicReviews(
    String establishmentId, {
    String? token,
  }) async {
    final json = await _api.get(
      '/api/establishments/$establishmentId/reviews',
      token: token,
    );
    return (json as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(PublicReview.fromJson)
        .toList();
  }

  Future<PublicCustomerProfile> publicProfile(
    String userId,
  ) async {
    final json = await _api.get('/api/public-profiles/$userId');
    return PublicCustomerProfile.fromJson(
      json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> vote({
    required String reviewId,
    required int value,
    required String token,
  }) async {
    final json = await _api.put(
      '/api/customer/reviews/$reviewId/vote',
      token: token,
      body: {'value': value},
    );
    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> removeVote({
    required String reviewId,
    required String token,
  }) async {
    final json = await _api.delete(
      '/api/customer/reviews/$reviewId/vote',
      token: token,
    );
    return json as Map<String, dynamic>;
  }
}
