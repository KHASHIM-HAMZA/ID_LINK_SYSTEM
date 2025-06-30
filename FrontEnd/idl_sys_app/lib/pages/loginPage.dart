import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController regOrUserController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isStudent = true; // toggle between student/admin

  bool isLoading = false;
  String error = '';

  Future<void> login() async {
    final username = regOrUserController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => error = "Please fill in all fields.");
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.post(
        Uri.parse(
          isStudent
              ? 'http://your-server/api/student/login'
              : 'http://your-server/api/admin/login',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          isStudent ? 'regNo' : 'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        Navigator.pushReplacementNamed(
          context,
          isStudent ? '/homePage' : '/dashBoard',
          arguments: userData,
        );
      } else {
        setState(() => error = "Invalid credentials.");
      }
    } catch (e) {
      setState(() => error = "Connection failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
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
                  isStudent ? "Student Login" : "Admin Login",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: regOrUserController,
                  decoration: InputDecoration(
                    labelText: isStudent ? "Registration Number" : "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
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
                  onPressed: isLoading ? null : login,
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
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => isStudent = !isStudent),
                  child: Text(
                    isStudent
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
