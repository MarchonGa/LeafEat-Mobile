import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/auth/data/auth_user.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<AuthResult> login({required String email, required String password}) async {
    final json = await _api.post('/api/auth/login', body: {
      'email': email.trim(),
      'password': password,
    });
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }

  Future<AuthResult> registerCustomer(Map<String, dynamic> body) async {
    final json = await _api.post('/api/auth/register/customer', body: body);
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }

  Future<AuthResult> registerRestaurant(Map<String, dynamic> body) async {
    final json = await _api.post('/api/auth/register/restaurant', body: body);
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }
}
