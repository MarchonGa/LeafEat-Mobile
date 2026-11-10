import 'package:leafeat_mobile/core/network/api_client.dart';
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

  Future<Dish> createDish(String establishmentId, Map<String, dynamic> body) async {
    final json = await _api.post(
      '/api/establishments/$establishmentId/dishes',
      body: body,
      token: token,
    );
    return Dish.fromJson(json as Map<String, dynamic>);
  }
}
