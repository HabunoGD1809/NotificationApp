import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:notification_app/config/app_config.dart';

class ApiService {
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update data');
    }
  }

  static Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('${AppConfig.apiBaseUrl}/$endpoint'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete data');
    }
  }
}
