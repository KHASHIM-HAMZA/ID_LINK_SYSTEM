import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Createrequestdialog extends StatefulWidget {
  const Createrequestdialog({super.key});

  @override
  State<Createrequestdialog> createState() => _CreaterequestdialogState();
}

class _CreaterequestdialogState extends State<Createrequestdialog> {
  final _formKey = GlobalKey<FormState>();

  String reg = '', name = '', year = '', course = '', email = '', phone = '';
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    ); // or .gallery
    if (pickedImage != null) {
      setState(() => _image = pickedImage);
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // TODO: Upload to API
      print('Sending request: $name, $reg, $year, $email');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create New ID Request'),
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
                          ? Icon(Icons.camera_alt)
                          : Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Reg'),
                onSaved: (v) => reg = v ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (v) => name = v ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Year'),
                onSaved: (v) => year = v ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Course'),
                onSaved: (v) => course = v ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (v) => email = v ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                onSaved: (v) => phone = v ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submitRequest, child: Text('Send Request')),
      ],
    );
  }
}
