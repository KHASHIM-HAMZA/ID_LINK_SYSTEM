import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:async/async.dart';

// Custom ImageProvider to include JWT token
class AuthenticatedNetworkImage
    extends ImageProvider<AuthenticatedNetworkImage> {
  final String url;
  final String token;

  AuthenticatedNetworkImage(this.url, this.token);

  @override
  Future<AuthenticatedNetworkImage> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<AuthenticatedNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    AuthenticatedNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync(
    AuthenticatedNetworkImage key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading image: $e');
      // Fallback to default image
      final byteData = await rootBundle.load('assets/default_profile.png');
      final bytes = byteData.buffer.asUint8List();
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return await decode(buffer);
    }
  }
}

class Profile extends StatefulWidget {
  final Map userData;

  const Profile({super.key, required this.userData});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isEditing = false;
  bool isEditingPassword = false;
  bool obscurePassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  XFile? _newImage;

  var error_outline_rounded;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final regNumber = userData['regNumber'];

        final response = await http.get(
          Uri.parse(
            '${AppConfig.baseUrl}/api/student/profile?regNumber=$regNumber',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            user = data;
            emailController.text = data['email'] ?? '';
            phoneController.text = data['phoneNo']?.toString() ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            user = userData;
            emailController.text = userData['email'] ?? '';
            phoneController.text = userData['phoneNo']?.toString() ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = picked);
    }
  }

  Future<void> _saveProfileChanges() async {
    if (user == null) return;

    try {
      final regNumber = user!['regNumber'];
      final uri = Uri.parse('${AppConfig.baseUrl}/api/student/update');

      final request = http.MultipartRequest('POST', uri);
      request.fields['regNumber'] = regNumber;
      request.fields['email'] = emailController.text;
      request.fields['phoneNo'] = phoneController.text;

      if (_newImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', _newImage!.path),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(responseData);
        await prefs.setString('userData', jsonEncode(updatedUser));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() {
          isEditing = false;
          user = updatedUser;
          _newImage = null;
        });
      } else {
        throw Exception(responseData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New passwords do not match'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/student/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'regNumber': user!['regNumber'],
          'currentPassword': currentPasswordController.text,
          'newPassword': newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() {
          isEditingPassword = false;
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        });
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildProfileHeader() {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('jwt_token'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          );
        }
        final token = snapshot.data;
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                backgroundImage:
                    _newImage != null
                        ? FileImage(File(_newImage!.path))
                        : (user!['photoUrl'] != null &&
                                    user!['photoUrl'].isNotEmpty
                                ? AuthenticatedNetworkImage(
                                  '${AppConfig.baseUrl}/api/student/uploads/photos?regNumber=${user!['regNumber']}',
                                  token ?? '',
                                )
                                : const AssetImage(
                                  'assets/default_profile.png',
                                ))
                            as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  print('Failed to load profile image: $exception');
                },
                child:
                    _newImage == null &&
                            (user!['photoUrl'] == null ||
                                user!['photoUrl'].isEmpty)
                        ? Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Colors.green.shade700,
                        )
                        : null,
              ),
            ).animate().fadeIn(duration: 600.ms).scale(),
            if (isEditing)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _pickNewImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRequestCountCard() {
    final requestCount = user?['requestCount'] ?? 0;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade500, Colors.green.shade800],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.request_page_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'ID Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              requestCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Requests',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onToggleObscure,
                )
                : null,
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildEditButtons({required VoidCallback onSave}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                isEditing = false;
                isEditingPassword = false;
                _newImage = null;
                emailController.text = user!['email'] ?? '';
                phoneController.text = user!['phoneNo']?.toString() ?? '';
                currentPasswordController.clear();
                newPasswordController.clear();
                confirmPasswordController.clear();
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildPasswordEditSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildEditableField(
              label: "Current Password",
              controller: currentPasswordController,
              icon: Icons.lock_rounded,
              isPassword: true,
              obscureText: obscurePassword,
              onToggleObscure:
                  () => setState(() => obscurePassword = !obscurePassword),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "New Password",
              controller: newPasswordController,
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              obscureText: obscureNewPassword,
              onToggleObscure:
                  () =>
                      setState(() => obscureNewPassword = !obscureNewPassword),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "Confirm New Password",
              controller: confirmPasswordController,
              icon: Icons.lock_reset_rounded,
              isPassword: true,
              obscureText: obscureConfirmPassword,
              onToggleObscure:
                  () => setState(
                    () => obscureConfirmPassword = !obscureConfirmPassword,
                  ),
            ),
            const SizedBox(height: 24),
            _buildEditButtons(onSave: _changePassword),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildProfileEditSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildEditableField(
              label: "Email Address",
              controller: emailController,
              icon: Icons.email_rounded,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "Phone Number",
              controller: phoneController,
              icon: Icons.phone_rounded,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => isEditingPassword = true),
                icon: Icon(Icons.lock_rounded, color: Colors.green.shade700),
                label: Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildEditButtons(onSave: _saveProfileChanges),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildProfileInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'Full Name',
              user!['fullName'] ?? '',
              Icons.person_rounded,
            ),
            _buildInfoField(
              'Registration Number',
              user!['regNumber'] ?? '',
              Icons.badge_rounded,
            ),
            _buildInfoField(
              'Course',
              user!['course'] ?? '',
              Icons.school_rounded,
            ),
            _buildInfoField(
              'Year of Study',
              user!['yearOfStudy'] ?? '',
              Icons.calendar_today_rounded,
            ),
            _buildInfoField('Email', user!['email'] ?? '', Icons.email_rounded),
            _buildInfoField(
              'Phone Number',
              user!['phoneNo']?.toString() ?? '',
              Icons.phone_rounded,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => isEditing = true),
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          ),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                error_outline_rounded,
                size: 60,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                "User data not found",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (!isEditing && !isEditingPassword)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => isEditing = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(child: _buildProfileHeader()),
            const SizedBox(height: 24),
            _buildRequestCountCard(),
            const SizedBox(height: 24),
            if (isEditingPassword)
              _buildPasswordEditSection()
            else if (isEditing)
              _buildProfileEditSection()
            else
              _buildProfileInfoSection(),
          ],
        ),
      ),
    );
  }
}
