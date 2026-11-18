import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/restaurant/data/nutritional_food.dart';

class NutritionalCatalogRepository {
  const NutritionalCatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<NutritionalFoodPage> search({
    String? search,
    String? preparation,
    String? category,
    int page = 1,
    int pageSize = 25,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search.trim().isNotEmpty)
        'search': search.trim(),
      if (preparation != null && preparation.trim().isNotEmpty)
        'preparation': preparation.trim(),
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
    };
    final queryString = Uri(queryParameters: query).query;
    final data = await _apiClient.get('/api/nutrition-foods?$queryString');
    return NutritionalFoodPage.fromJson(data as Map<String, dynamic>);
  }
}
