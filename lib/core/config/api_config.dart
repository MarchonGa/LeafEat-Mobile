import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  const ApiConfig._();

  static const _defaultBaseUrl = 'http://localhost:5000';

  static String get baseUrl {
    const compileTimeUrl = String.fromEnvironment('API_BASE_URL');
    if (compileTimeUrl.isNotEmpty) return compileTimeUrl;

    if (!dotenv.isInitialized) return _defaultBaseUrl;
    return dotenv.maybeGet(
          'API_BASE_URL',
          fallback: _defaultBaseUrl,
        ) ??
        _defaultBaseUrl;
  }
}
