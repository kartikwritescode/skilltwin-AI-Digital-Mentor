class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://skilltwin-backend.onrender.com/api/v1',
  );

  static const String rootUrl = 'https://skilltwin-backend.onrender.com';

  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
