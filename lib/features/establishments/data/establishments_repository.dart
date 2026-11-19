import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/establishments/data/dish_search_result.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/dish.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';

class EstablishmentsRepository {
  EstablishmentsRepository(this._api, {this.token});

  final ApiClient _api;
  final String? token;

  Future<List<Establishment>> list() async {
    final json = await _api.get('/api/establishments');
    final summaries = json as List<dynamic>;
    return Future.wait(
      summaries.map((item) => detail((item as Map<String, dynamic>)['id'] as String)),
    );
  }

  Future<Establishment> detail(String id) async {
    final json = await _api.get('/api/establishments/$id');
    return Establishment.fromJson(json as Map<String, dynamic>);
  }

  Future<List<DishSearchResult>> searchDishes({
    int? calories,
    double? proteinGrams,
    double? carbohydrateGrams,
    double? fatGrams,
    bool vegan = false,
    bool lactoseFree = false,
  }) async {
    final parameters = <String, String>{
      if (calories != null) 'calories': calories.toString(),
      if (proteinGrams != null)
        'proteinGrams': proteinGrams.toString(),
      if (carbohydrateGrams != null)
        'carbohydrateGrams': carbohydrateGrams.toString(),
      if (fatGrams != null) 'fatGrams': fatGrams.toString(),
      if (vegan) 'vegan': 'true',
      if (lactoseFree) 'lactoseFree': 'true',
    };
    final query = Uri(queryParameters: parameters).query;
    final json = await _api.get('/api/dishes/search?$query');
    return (json as List<dynamic>)
        .map((item) => DishSearchResult.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList(growable: false);
  }

  Future<Dish> createDish(String establishmentId, Map<String, dynamic> body) async {
    final json = await _api.post(
      '/api/establishments/$establishmentId/dishes',
      body: body,
      token: token,
    );
    return Dish.fromJson(json as Map<String, dynamic>);
  }
}
