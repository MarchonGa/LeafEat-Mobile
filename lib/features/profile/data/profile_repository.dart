import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/profile/data/account_profile.dart';

class ProfileRepository {
  const ProfileRepository(this._api, this._token);

  final ApiClient _api;
  final String _token;

  Future<AccountProfile> profile() async {
    final json = await _api.get('/api/profile/', token: _token);
    return AccountProfile.fromJson(json as Map<String, dynamic>);
  }

  Future<AccountProfile> updateCustomer(Map<String, dynamic> body) async {
    final json = await _api.put(
      '/api/profile/customer',
      body: body,
      token: _token,
    );
    return AccountProfile.fromJson(json as Map<String, dynamic>);
  }

  Future<AccountProfile> updateRestaurant(Map<String, dynamic> body) async {
    final json = await _api.put(
      '/api/profile/restaurant',
      body: body,
      token: _token,
    );
    return AccountProfile.fromJson(json as Map<String, dynamic>);
  }
}
