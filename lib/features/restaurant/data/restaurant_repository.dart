import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_dashboard.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_review.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_visit.dart';

class RestaurantRepository {
  const RestaurantRepository(this._api, this._token);

  final ApiClient _api;
  final String _token;

  Future<Dish> createDish(
    String establishmentId,
    Map<String, dynamic> body,
  ) async {
    final json = await _api.post(
      '/api/establishments/$establishmentId/dishes',
      body: body,
      token: _token,
    );
    return Dish.fromJson(json as Map<String, dynamic>);
  }

  Future<Dish> updateDish(
    String establishmentId,
    String dishId,
    Map<String, dynamic> body,
  ) async {
    final json = await _api.put(
      '/api/establishments/$establishmentId/dishes/$dishId',
      body: body,
      token: _token,
    );
    return Dish.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteDish(
    String establishmentId,
    String dishId,
  ) =>
      _api.delete(
        '/api/establishments/$establishmentId/dishes/$dishId',
        token: _token,
      );

  Future<List<RestaurantVisit>> visits() async {
    final json = await _api.get(
      '/api/restaurant/visits',
      token: _token,
    ) as List<dynamic>;
    return json
        .map((item) =>
            RestaurantVisit.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> confirmVisit(String id, String code) => _api.put(
        '/api/restaurant/visits/$id/confirm',
        body: {'confirmationCode': code},
        token: _token,
      );

  Future<void> markNoShow(String id) => _api.put(
        '/api/restaurant/visits/$id/no-show',
        token: _token,
      );

  Future<void> respondToReview(String id, String message) => _api.put(
        '/api/restaurant/reviews/$id/response',
        body: {'message': message},
        token: _token,
      );

  Future<void> saveReviewInternalNote(String id, String? note) => _api.put(
        '/api/restaurant/reviews/$id/internal-note',
        body: {'note': note},
        token: _token,
      );

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
