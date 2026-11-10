import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/user_mode.dart';
import 'package:leafeat_mobile/core/network/api_client.dart';
import 'package:leafeat_mobile/features/auth/data/auth_repository.dart';
import 'package:leafeat_mobile/features/auth/data/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:leafeat_mobile/app/session/user_mode.dart';

class AppSession extends ChangeNotifier {
  AppSession({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient() {
    authRepository = AuthRepository(this.apiClient);
  }

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  SharedPreferencesAsync get _preferences => SharedPreferencesAsync();

  final ApiClient apiClient;
  late final AuthRepository authRepository;
  UserMode _mode = UserMode.guest;
  String? _token;
  AuthUser? _user;
  bool _restored = false;

  UserMode get mode => _mode;
  String? get token => _token;
  AuthUser? get user => _user;
  bool get restored => _restored;

  bool get isAuthenticated => _mode != UserMode.guest;

  Future<void> restore() async {
    try {
      final token = await _preferences.getString(_tokenKey);
      final userJson = await _preferences.getString(_userKey);
      if (token != null && userJson != null) {
        _token = token;
        _user = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        _mode = _user!.role;
      }
    } catch (_) {
      try {
        await _preferences.remove(_tokenKey);
        await _preferences.remove(_userKey);
      } catch (_) {}
    }
    _restored = true;
    notifyListeners();
  }

  Future<void> authenticate(AuthResult result) async {
    _token = result.token;
    _user = result.user;
    _mode = result.user.role;
    await _preferences.setString(_tokenKey, result.token);
    await _preferences.setString(_userKey, jsonEncode(result.user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _mode = UserMode.guest;
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_userKey);
    notifyListeners();
  }

  void switchMode(UserMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  @override
  void dispose() {
    apiClient.close();
    super.dispose();
  }
}

class AppSessionScope extends InheritedNotifier<AppSession> {
  const AppSessionScope({required AppSession notifier, required super.child, super.key})
      : super(notifier: notifier);

  static AppSession watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSessionScope>();
    assert(scope != null, 'AppSessionScope não encontrado.');
    return scope!.notifier!;
  }

  static AppSession read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppSessionScope>();
    final scope = element?.widget as AppSessionScope?;
    assert(scope != null, 'AppSessionScope não encontrado.');
    return scope!.notifier!;
  }

  static AppSession? maybeRead(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppSessionScope>();
    final scope = element?.widget as AppSessionScope?;
    return scope?.notifier;
  }
}