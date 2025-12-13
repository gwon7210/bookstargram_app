class AuthTokenStore {
  AuthTokenStore._();

  static final AuthTokenStore instance = AuthTokenStore._();

  String? _token;

  String? get token => _token;

  void save(String token) {
    _token = token;
  }

  void clear() {
    _token = null;
  }
}
