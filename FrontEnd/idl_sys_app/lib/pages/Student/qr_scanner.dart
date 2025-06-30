import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QrScannner extends StatefulWidget {
  const QrScannner({super.key});

  @override
  State<QrScannner> createState() => _QrScannnerState();
}

class _QrScannnerState extends State<QrScannner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Map<String, dynamic>? studentData;
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (studentData == null && !isLoading) {
        final qrCode = scanData.code ?? '';
        _fetchStudentDetails(qrCode);
        controller.pauseCamera();
      }
    });
  }

  Future<void> _fetchStudentDetails(String qrCode) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/students/scan/$qrCode"),
      );

      if (response.statusCode == 200) {
        setState(() {
          studentData = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = "Student not found or invalid QR code.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error connecting to server: $e";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Student ID"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          if (studentData == null && !isLoading && errorMessage.isEmpty)
            Expanded(
              flex: 4,
              child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
            ),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (studentData != null)
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${studentData!['name']}"),
                      Text("Reg No: ${studentData!['regNo']}"),
                      Text("Course: ${studentData!['course']}"),
                      Text("Year: ${studentData!['year']}"),
                      Text("Email: ${studentData!['email']}"),
                      Text("Phone: ${studentData!['phone']}"),
                    ],
                  ),
                ),
              ),
            ),
          if (errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    studentData = null;
                    errorMessage = "";
                  });
                  controller?.resumeCamera();
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('Rescan'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
