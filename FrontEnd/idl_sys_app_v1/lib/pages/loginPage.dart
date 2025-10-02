import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/Admin/admin_Dashboard.dart';
import 'package:idl_sys_app_v1/pages/Student/homePage.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:idl_sys_app_v1/pages/transition%20screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _regOrUserController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isStudent = true; // Toggle between student/admin
  bool _isLoading = false;
  String _error = '';

  Future<void> _login() async {
    final usernameOrRegNumber = _regOrUserController.text.trim();
    final password = _passwordController.text;

    if (usernameOrRegNumber.isEmpty || password.isEmpty) {
      setState(() => _error = "Please fill in all fields.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.post(
        Uri.parse(
          _isStudent
              ? '${AppConfig.baseUrl}/api/student/login'
              : '${AppConfig.baseUrl}/api/auth/admin-login',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          _isStudent ? 'regNumber' : 'username': usernameOrRegNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final token = userData['token'];
        if (token == null) throw Exception('Token not found in response');

        // Ensure role has ROLE_ prefix if it doesn't already
        String role = userData['role'];
        if (!role.startsWith('ROLE_')) {
          role = 'ROLE_$role';
          userData['role'] = role;
        }

        // Save token and userData to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('userData', jsonEncode(userData));

        // Navigate based on role
        if (_isStudent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TransitionScreen(
                    nextScreen: Homepage(userData: userData),
                  ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TransitionScreen(nextScreen: AdminDashboard()),
            ),
          );
        }
      } else {
        setState(
          () =>
              _error =
                  "Invalid credentials. Status: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      setState(() => _error = "Connection failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _regOrUserController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.school_outlined, size: 100),
                const SizedBox(height: 16),
                Text(
                  _isStudent ? "Student Login" : "Admin Login",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _regOrUserController,
                  decoration: InputDecoration(
                    labelText: _isStudent ? "Registration Number" : "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText: _error.isNotEmpty ? _error : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _isStudent = !_isStudent),
                  child: Text(
                    _isStudent
                        ? "Are you an admin? Login here"
                        : "Are you a student? Login here",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
