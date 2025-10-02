import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idl_sys_app_v1/pages/config.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;

  // Helper method to get authentication token and headers (made public)
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userData = prefs.getString('userData');
    String role = '';

    if (userData != null) {
      try {
        final user = jsonDecode(userData);
        role = user['role'] ?? '';
        // Ensure role has ROLE_ prefix if it doesn't
        if (role.isNotEmpty && !role.startsWith('ROLE_')) {
          role = 'ROLE_$role';
        }
      } catch (e) {
        print('Error parsing userData: $e');
      }
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Role': role,
    };
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      print('GET $endpoint - Status: ${response.statusCode}'); // Debug
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(
          'Failed to load data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(
          'Failed to update: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(
          'Failed to create: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  static Future<Uint8List> getBinary(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      print(
        'GET BINARY $endpoint - Status: ${response.statusCode}, Body length: ${response.bodyBytes.length}',
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(
          'Failed to load binary data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }
}
