enum AppEnvironment { dev, prod }

class EnvironmentConfig {
  static const String _envName =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

  static AppEnvironment get environment =>
      _envName.toLowerCase() == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;

  static const String _devBaseUrl =
      String.fromEnvironment('DEV_API_URL', defaultValue: 'http://192.168.0.187:3000');

  static const String _prodBaseUrl = String.fromEnvironment(
    'PROD_API_URL',
    defaultValue: 'https://bookstagram.example.com',
  );

  static String get apiBaseUrl =>
      environment == AppEnvironment.prod ? _prodBaseUrl : _devBaseUrl;

  static Uri apiUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$apiBaseUrl$normalizedPath');
  }
}
