import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool _scanned = false;
  Map<String, dynamic>? studentData;

  Future<void> fetchStudentDetails(String qrCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // ✅ use request param ?regNumber=...
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/student/verify?regNumber=$qrCode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          studentData = json.decode(response.body);
          _scanned = true;
        });
      } else {
        _showSnackBar("Student not found!");
      }
    } catch (e) {
      _showSnackBar("Error fetching student details.");
    }
  }

  Future<void> sendMessage(String message) async {
    if (studentData == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // ✅ pass regNumber as request param
      final response = await http.post(
        Uri.parse(
          '${ApiService.baseUrl}/api/qr/message?regNumber=${studentData!["regNumber"]}',
        ),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "senderName": "App User", // or get from logged-in student
          "senderContact": "N/A", // you can fetch from profile
          "messageText": message,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // close dialog
        _showSnackBar("Message sent successfully!");
      } else {
        _showSnackBar("Failed to send message.");
      }
    } catch (e) {
      _showSnackBar("Error sending message.");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openMessageDialog() {
    TextEditingController msgController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text("Send Message"),
            content: TextField(
              controller: msgController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (msgController.text.trim().isNotEmpty) {
                    sendMessage(msgController.text.trim());
                  } else {
                    _showSnackBar("Message cannot be empty");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Send"),
              ),
            ],
          ),
    );
  }

  Widget _buildStudentCard() {
    if (studentData == null) return const SizedBox();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 50, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              studentData!["fullName"] ?? "Unknown",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Email: ${studentData!["email"] ?? "N/A"}"),
            Text("Phone: ${studentData!["phoneNo"] ?? "N/A"}"),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text("Call"),
                  onPressed:
                      () => launchUrl(
                        Uri.parse("tel:${studentData!["phoneNo"]}"),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text("Email"),
                  onPressed:
                      () => launchUrl(
                        Uri.parse("mailto:${studentData!["email"]}"),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text("In-App Message"),
                  onPressed: _openMessageDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body:
          !_scanned
              ? Column(
                children: [
                  Expanded(
                    child: MobileScanner(
                      onDetect: (barcodeCapture) {
                        final barcode = barcodeCapture.barcodes.first.rawValue;
                        if (barcode != null && !_scanned) {
                          fetchStudentDetails(barcode);
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Point the camera at a QR code",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              )
              : _buildStudentCard(),
      floatingActionButton:
          _scanned
              ? FloatingActionButton(
                onPressed: () => setState(() => _scanned = false),
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.qr_code_scanner),
              )
              : null,
    );
  }
}
