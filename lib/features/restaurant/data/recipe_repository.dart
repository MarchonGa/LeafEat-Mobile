import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/restaurant/data/restaurant_recipe.dart';

class RecipeRepository {
  const RecipeRepository(this._apiClient, this._token);

  final ApiClient _apiClient;
  final String _token;

  Future<List<RestaurantRecipe>> list(String establishmentId) async {
    final data = await _apiClient.get(
      '/api/establishments/$establishmentId/recipes',
      token: _token,
    );
    return (data as List)
        .whereType<Map<String, dynamic>>()
        .map(RestaurantRecipe.fromJson)
        .toList(growable: false);
  }

  Future<RestaurantRecipe> create({
    required String establishmentId,
    required String name,
    required String description,
    required double finalWeightGrams,
    required List<NutritionalFoodSelection> ingredients,
  }) async {
    final data = await _apiClient.post(
      '/api/establishments/$establishmentId/recipes',
      token: _token,
      body: {
        'name': name,
        'description': description,
        'finalWeightGrams': finalWeightGrams,
        'ingredients':
            ingredients.map((item) => item.toRequestJson()).toList(),
      },
    );
    return RestaurantRecipe.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete({
    required String establishmentId,
    required String recipeId,
  }) =>
      _apiClient.delete(
        '/api/establishments/$establishmentId/recipes/$recipeId',
        token: _token,
      );
}
