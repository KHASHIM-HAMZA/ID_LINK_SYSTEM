import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class CreateRequest extends StatefulWidget {
  const CreateRequest({super.key});

  @override
  State<CreateRequest> createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String reg = '', name = '', year = '', course = '', email = '', phone = '';
  XFile? _image;
  Uint8List? _imageBytes;
  Uint8List? _reportBytes;
  String? _reportName;
  int requestCount = 0;
  bool _isSubmitting = false;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('userData');
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        setState(() {
          reg = userData['regNumber']?.toString() ?? '';
          name = userData['fullName']?.toString() ?? '';
          course = userData['course']?.toString() ?? '';
          year = userData['yearOfStudy']?.toString() ?? '';
          email = userData['email']?.toString() ?? '';
          phone = userData['phoneNo']?.toString() ?? '';
          requestCount = userData['requestCount'] ?? 0;
          _isLoadingUserData = false;
        });
      } else {
        setState(() => _isLoadingUserData = false);
      }
    } catch (e) {
      setState(() => _isLoadingUserData = false);
      _showError('Failed to load user data: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      // Validate file extension
      final extension = pickedImage.name.toLowerCase();
      if (!extension.endsWith('.jpg') &&
          !extension.endsWith('.jpeg') &&
          !extension.endsWith('.png')) {
        _showError("Only JPG, JPEG, or PNG images are allowed.");
        return;
      }

      // Validate file size
      final bytes = await pickedImage.length();
      if (bytes > 2 * 1024 * 1024) {
        _showError("Image too large. Max 2MB allowed.");
        return;
      }

      // Load image bytes for preview
      final imageBytes = await pickedImage.readAsBytes();

      setState(() {
        _image = pickedImage;
        _imageBytes = imageBytes;
      });
    } catch (e) {
      _showError("Error selecting image: ${e.toString()}");
      debugPrint("Image picker error: $e");
    }
  }

  Future<void> _pickReport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.size > 5 * 1024 * 1024) {
        _showError("File too large. Max 5MB allowed.");
        return;
      }

      _reportName = file.name;

      if (kIsWeb) {
        _reportBytes = file.bytes!;
      } else {
        _reportBytes = await File(file.path!).readAsBytes();
      }

      setState(() {});
    } catch (e) {
      _showError("Error selecting file: ${e.toString()}");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      _showError('Please select a passport photo');
      return;
    }
    if (requestCount >= 3 && _reportBytes == null) {
      _showError('Please attach a report PDF');
      return;
    }

    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();

    try {
      final requestData = {
        'fullName': name,
        'regNumber': reg,
        'course': course,
        'yearOfStudy': year,
        'email': email,
        'phoneNo': phone,
      };

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/student/request-with-photo'),
      );

      // Use ApiService headers
      final headers = await ApiService.getHeaders();
      request.headers.addAll(headers);

      request.fields.addAll(
        requestData.map((key, value) => MapEntry(key, value.toString())),
      );

      // Add photo file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _imageBytes!,
          filename: _image!.name,
        ),
      );

      // Add report file if attached
      if (_reportBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'reportFile',
            _reportBytes!,
            filename: _reportName,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.of(context).pop();
          _showSuccess('ID request submitted successfully');
        }
      } else {
        throw Exception(
          'Request failed with status ${response.statusCode}: $responseBody',
        );
      }
    } catch (e) {
      _showError('Submission error: ${e.toString()}');
      debugPrint("Submit error: $e");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPhotoUploadSection(),
                const SizedBox(height: 24),
                if (requestCount >= 3) _buildReportUploadSection(),
                const SizedBox(height: 24),
                if (_isLoadingUserData)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green.shade700,
                      ),
                    ),
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 300),
                  )
                else
                  ..._buildFormFields(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.add_circle_rounded, color: Colors.green.shade700, size: 28),
        const SizedBox(width: 8),
        Text(
          'New ID Request',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      children: [
        Text(
          'Upload Passport Photo',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                _imageBytes == null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 40,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    ),
          ),
        ).animate().scale(duration: const Duration(milliseconds: 400)),
        const SizedBox(height: 8),
        Text(
          'JPG/PNG, max 2MB',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildReportUploadSection() {
    return Column(
      children: [
        Text(
          'Attach Report (PDF required)',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickReport,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                _reportBytes == null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 40,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 40,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Report Selected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
          ),
        ).animate().scale(duration: const Duration(milliseconds: 400)),
        const SizedBox(height: 8),
        Text(
          'PDF, max 5MB',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildTextField(
        label: 'Registration Number',
        initialValue: reg,
        onSaved: (v) => reg = v ?? '',
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        icon: Icons.badge_rounded,
        readOnly: true, // Always read-only as from user data
      ),
      _buildTextField(
        label: 'Full Name',
        initialValue: name,
        onSaved: (v) => name = v ?? '',
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        icon: Icons.person_rounded,
        readOnly: name.isNotEmpty,
      ),
      _buildTextField(
        label: 'Year of Study',
        initialValue: year,
        onSaved: (v) => year = v ?? '',
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        icon: Icons.school_rounded,
        readOnly: year.isNotEmpty,
      ),
      _buildTextField(
        label: 'Course',
        initialValue: course,
        onSaved: (v) => course = v ?? '',
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        icon: Icons.menu_book_rounded,
        readOnly: course.isNotEmpty,
      ),
      _buildTextField(
        label: 'Email',
        initialValue: email,
        onSaved: (v) => email = v ?? '',
        validator: (v) {
          if (v?.isEmpty ?? true) ;
          if (!v!.contains('@')) return 'Invalid email';
          return null;
        },
        icon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      _buildTextField(
        label: 'Phone Number',
        initialValue: phone,
        onSaved: (v) => phone = v ?? '',
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        icon: Icons.phone_rounded,
        keyboardType: TextInputType.phone,
      ),
    ];
  }

  Widget _buildTextField({
    required String label,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    IconData? icon,
    TextInputType? keyboardType,
    String? initialValue,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon:
              icon != null
                  ? Icon(icon, color: Colors.green.shade700, size: 20)
                  : null,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.green.shade50,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,
        readOnly: readOnly,
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text(
                    'Submit Request',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
        ),
      ],
    ).animate().slideY(
      begin: 0.2,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }
}
