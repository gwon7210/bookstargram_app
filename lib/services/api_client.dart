import 'package:http/http.dart' as http;

import '../config/environment.dart';
import 'auth_token_store.dart';

class ApiClient {
  const ApiClient();

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    final uri = EnvironmentConfig.apiUri(path);
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    if (authenticated) {
      final token = AuthTokenStore.instance.token;
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    // ignore: avoid_print
    print('[ApiClient] GET $uri headers=$requestHeaders');

    return http.get(uri, headers: requestHeaders);
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) async {
    final uri = EnvironmentConfig.apiUri(path);
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    if (authenticated) {
      final token = AuthTokenStore.instance.token;
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    // ignore: avoid_print
    print('[ApiClient] POST $uri headers=$requestHeaders body=$body');

    return http.post(uri, headers: requestHeaders, body: body);
  }

  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool authenticated = true,
  }) async {
    final uri = EnvironmentConfig.apiUri(path);
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    if (authenticated) {
      final token = AuthTokenStore.instance.token;
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    // ignore: avoid_print
    print('[ApiClient] PATCH $uri headers=$requestHeaders body=$body');

    return http.patch(uri, headers: requestHeaders, body: body);
  }
}
