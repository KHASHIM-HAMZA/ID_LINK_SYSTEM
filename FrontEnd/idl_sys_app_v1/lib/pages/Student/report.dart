import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';

class LossReportPage extends StatefulWidget {
  @override
  _LossReportPageState createState() => _LossReportPageState();
}

class _LossReportPageState extends State<LossReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedPdf;
  bool _isSubmitting = false;

  // Function to pick PDF
  Future<void> pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
      });
    }
  }

  // Function to submit form
  Future<void> submitReport() async {
    if (!_formKey.currentState!.validate() || _selectedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and attach a PDF')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/student/loss-report'),
      );

      request.fields['description'] = _descriptionController.text;
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf',
          _selectedPdf!.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully!')),
        );
        _descriptionController.clear();
        setState(() {
          _selectedPdf = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit report.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Lost ID')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Describe the loss',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.attach_file),
                label: Text(
                  _selectedPdf == null
                      ? 'Attach PDF'
                      : 'PDF Selected: ${_selectedPdf!.path.split('/').last}',
                ),
                onPressed: pickPdf,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : submitReport,
                child:
                    _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
