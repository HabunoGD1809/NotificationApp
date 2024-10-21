class AppConfig {
  static const String appName = 'Notification App';
  static const String apiBaseUrl = 'http://0.0.0.0:8000'; // URL de tu backend

  // Derivamos la URL de WebSocket de la URL de la API
  static String get wsUrl {
    final uri = Uri.parse(apiBaseUrl);
    return 'ws://${uri.host}:${uri.port}';
  }
}