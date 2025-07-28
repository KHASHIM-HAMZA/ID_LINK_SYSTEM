import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/config.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDigitalIDs extends StatefulWidget {
  const AdminDigitalIDs({super.key});

  @override
  State<AdminDigitalIDs> createState() => _AdminDigitalIDsState();
}

class _AdminDigitalIDsState extends State<AdminDigitalIDs> {
  List students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApprovedIDs();
  }

  Future<void> fetchApprovedIDs() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/print/all-approved'),
    );

    if (response.statusCode == 200) {
      setState(() {
        students = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load approved IDs')),
      );
    }
  }

  void openPDF(String regNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(regNumber: regNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approved Student IDs'),
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : students.isEmpty
              ? const Center(child: Text('No approved IDs found'))
              : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          '${AppConfig.baseUrl}/api/student/photo/${student['regNumber']}',
                        ),
                        radius: 25,
                      ),
                      title: Text(student['fullName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student['regNumber']),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Approved',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      student['printed']
                                          ? Colors.blue[100]
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  student['printed']
                                      ? 'Printed'
                                      : 'Not Printed',
                                  style: TextStyle(
                                    color:
                                        student['printed']
                                            ? Colors.blue
                                            : Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => openPDF(student['regNumber']),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String regNumber;

  const PDFViewerPage({super.key, required this.regNumber});

  Future<void> downloadPDF(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfUrl = '${AppConfig.baseUrl}/api/print/view?regNumber=$regNumber';
    final downloadUrl = pdfUrl; // Same as viewing URL

    return Scaffold(
      appBar: AppBar(
        title: Text('ID Card: $regNumber'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(child: SfPdfViewer.network(pdfUrl)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
              onPressed: () => downloadPDF(downloadUrl),
            ),
          ),
        ],
      ),
    );
  }
}
