class AppConfig {
  static const String appName = 'Notification App';
  static const String apiBaseUrl = 'http://10.0.2.2:8000';

  // Derivamos la URL de WebSocket de la URL de la API
  static String get wsUrl {
    final uri = Uri.parse(apiBaseUrl);
    return 'ws://${uri.host}:${uri.port}';
  }
}