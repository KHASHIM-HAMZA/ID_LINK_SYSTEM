import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api';

  // Login for admin
  Future<Map<String, dynamic>> loginAdmin(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/admin-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _saveToken(token);
      return {'success': true, 'token': token, 'role': data['role']};
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Login for student
  Future<Map<String, dynamic>> loginStudent(
    String regNumber,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/student/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'regNumber': regNumber, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _saveToken(token);
      return {'success': true, 'token': token, 'role': data['role']};
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Logout (clear token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
