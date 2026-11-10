import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:leafeat_mobile/core/config/api_config.dart';
import 'package:leafeat_mobile/core/network/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _httpClient = httpClient ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _httpClient;
  final String baseUrl;

  Future<dynamic> get(String path, {String? token}) async {
    final response = await _send(() => _httpClient.get(
          Uri.parse('$baseUrl$path'),
          headers: _headers(token: token),
        ));
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body, String? token}) async {
    final response = await _send(() => _httpClient.post(
          Uri.parse('$baseUrl$path'),
          headers: _headers(token: token),
          body: jsonEncode(body),
        ));
    return _decode(response);
  }

  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 12));
    } catch (_) {
      throw const ApiException(
        'Não foi possível acessar a API. Confirme se o backend está em execução.',
      );
    }
  }

  dynamic _decode(http.Response response) {
    dynamic data;
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        data = response.body;
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    var message = 'A operação não pôde ser concluída.';
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? _validationMessage(data) ?? message;
    }
    throw ApiException(message, statusCode: response.statusCode);
  }

  String? _validationMessage(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is! Map) return null;
    return errors.values
        .whereType<List>()
        .expand((messages) => messages)
        .map((message) => message.toString())
        .join('\n');
  }

  void close() => _httpClient.close();
}
