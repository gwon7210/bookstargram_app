import 'dart:convert';

import 'api_client.dart';
import 'auth_token_store.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  AuthService({
    ApiClient? apiClient,
    AuthTokenStore? tokenStore,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStore = tokenStore ?? AuthTokenStore.instance;

  final ApiClient _apiClient;
  final AuthTokenStore _tokenStore;

  Future<String> login(String loginId) async {
    final requestBody = jsonEncode({'loginId': loginId});
    final response = await _apiClient.post(
      '/auth/login',
      body: requestBody,
      authenticated: false,
    );

    if (response.statusCode != 200) {
      final responseBody = _tryDecodeBody(response.body);
      final serverMessage = responseBody?['message'] as String?;
      throw AuthException(
        serverMessage ?? '로그인에 실패했습니다. (${response.statusCode})',
      );
    }

    final responseBody = _decodeBody(response.body);
    final token = responseBody['accessToken'] as String?;

    if (token == null) {
      throw const FormatException('JWT 토큰을 찾을 수 없습니다.');
    }

    _tokenStore.save(token);

    return token;
  }

  Map<String, dynamic> _decodeBody(String responseBody) =>
      jsonDecode(responseBody) as Map<String, dynamic>;

  Map<String, dynamic>? _tryDecodeBody(String responseBody) {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
