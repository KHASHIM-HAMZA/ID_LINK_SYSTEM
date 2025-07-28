import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:image_picker/image_picker.dart';

class CreateRequest extends StatefulWidget {
  const CreateRequest({super.key});

  @override
  State<CreateRequest> createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  final _formKey = GlobalKey<FormState>();

  String reg = '', name = '', year = '', course = '', email = '', phone = '';
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() => _image = pickedImage);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a photo')));
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/student/request-with-photo'),
      );

      // Add form fields
      request.fields['fullName'] = name;
      request.fields['regNumber'] = reg;
      request.fields['course'] = course;
      request.fields['yearOfStudy'] = year;
      request.fields['email'] = email;
      request.fields['phoneNo'] = phone;

      // Attach image file
      request.files.add(
        await http.MultipartFile.fromPath('file', _image!.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Request and photo sent successfully.');
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully')),
        );
      } else {
        throw Exception(
          'Failed to send request. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New ID Request'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[300],
                  child:
                      _image == null
                          ? const Icon(Icons.camera_alt)
                          : Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Reg Number'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => reg = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => name = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => year = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Course'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => course = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => email = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) => phone = v ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitRequest,
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}
