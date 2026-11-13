import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/customer/data/customer_review.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_entry.dart';
import 'package:leafeat_mobile/features/customer/data/nutrition_goals.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';

class CustomerRepository {
  const CustomerRepository(this._api, this._token);

  final ApiClient _api;
  final String _token;

  Future<List<Establishment>> favorites() async {
    final json = await _api.get('/api/customer/favorites', token: _token) as List<dynamic>;
    return json.map((item) => Establishment.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> addFavorite(String establishmentId) => _api.post(
        '/api/customer/favorites/$establishmentId', token: _token);

  Future<void> removeFavorite(String establishmentId) => _api.delete(
        '/api/customer/favorites/$establishmentId', token: _token);

  Future<List<CustomerReview>> reviews() async {
    final json = await _api.get('/api/customer/reviews', token: _token) as List<dynamic>;
    return json.map((item) => CustomerReview.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<CustomerReview> createReview(Map<String, dynamic> body) async {
    final json = await _api.post('/api/customer/reviews', body: body, token: _token);
    return CustomerReview.fromJson(json as Map<String, dynamic>);
  }

  Future<NutritionDay> nutritionFor(DateTime date) async {
    final value = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final json = await _api.get('/api/customer/nutrition?date=$value', token: _token);
    return NutritionDay.fromJson(json as Map<String, dynamic>);
  }

  Future<NutritionEntry> addNutrition(Map<String, dynamic> body) async {
    final json = await _api.post('/api/customer/nutrition', body: body, token: _token);
    return NutritionEntry.fromJson(json as Map<String, dynamic>);
  }

  Future<void> removeNutrition(String id) =>
      _api.delete('/api/customer/nutrition/$id', token: _token);

  Future<NutritionGoals> nutritionGoals() async {
    final json = await _api.get('/api/customer/nutrition-goals', token: _token);
    return NutritionGoals.fromJson(json as Map<String, dynamic>);
  }

  Future<NutritionGoals> updateNutritionGoals(NutritionGoals goals) async {
    final json = await _api.put(
      '/api/customer/nutrition-goals',
      body: goals.toJson(),
      token: _token,
    );
    return NutritionGoals.fromJson(json as Map<String, dynamic>);
  }
}
