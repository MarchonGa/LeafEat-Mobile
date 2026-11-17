import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_dashboard.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_review.dart';

class RestaurantRepository {
  const RestaurantRepository(this._api, this._token);

  final ApiClient _api;
  final String _token;

  Future<List<RestaurantReview>> reviews() async {
    final json = await _api.get(
      '/api/restaurant/reviews',
      token: _token,
    ) as List<dynamic>;
    return json
        .map((item) => RestaurantReview.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<RestaurantDashboard> dashboard() async {
    final json = await _api.get(
      '/api/restaurant/dashboard',
      token: _token,
    );
    return RestaurantDashboard.fromJson(json as Map<String, dynamic>);
  }
}
