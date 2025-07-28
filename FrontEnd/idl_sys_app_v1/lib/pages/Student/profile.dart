import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required Map userData});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  XFile? _newImage;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      final regNumber = userData['regNumber'];

      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/profile?regNumber=${Uri.encodeComponent(regNumber)}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          user = data;
          emailController.text = data['email'] ?? '';
          phoneController.text =
              data['phoneNo'] != null ? data['phoneNo'].toString() : '';
          isLoading = false;
        });
      } else {
        // fallback to local data if API fails
        setState(() {
          user = userData;
          emailController.text = userData['email'] ?? '';
          phoneController.text =
              userData['phoneNo'] != null ? userData['phoneNo'].toString() : '';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (user == null) return;

    final regNumber = user!['regNumber'];
    final uri = Uri.parse('${AppConfig.baseUrl}/api/student/update/$regNumber');

    final request = http.MultipartRequest('PUT', uri);

    request.fields['email'] = emailController.text;
    request.fields['phoneNo'] = phoneController.text;

    if (_newImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', _newImage!.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      loadUserData(); // refresh data after update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile. Status: ${response.statusCode}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User data not found.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickNewImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    _newImage != null
                        ? FileImage(File(_newImage!.path))
                        : (user!['photoUrl'] != null
                            ? NetworkImage(user!['photoUrl']) as ImageProvider
                            : const AssetImage('lib/components/IMG_2809.jpg')),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user!['fullName'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Reg: ${user!['regNumber'] ?? ''}"),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone No",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
