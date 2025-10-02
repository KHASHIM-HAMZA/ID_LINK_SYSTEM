import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';

class AdminDigitalIDs extends StatefulWidget {
  const AdminDigitalIDs({super.key});

  @override
  State<AdminDigitalIDs> createState() => _AdminDigitalIDsState();
}

class _AdminDigitalIDsState extends State<AdminDigitalIDs> {
  List<dynamic> students = [];
  bool isLoading = true;
  String? errorMessage;
  final Map<String, bool> _printingStatus = {};

  @override
  void initState() {
    super.initState();
    _loadApprovedIDs();
  }

  Future<void> _loadApprovedIDs() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await ApiService.get('api/print/all-approved');

      if (response is List) {
        setState(() {
          students = response;
          for (var student in students) {
            final regNumber = student['regNumber']?.toString() ?? '';
            _printingStatus[regNumber] = student['printed'] ?? false;
          }
          isLoading = false;
        });
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load approved IDs: ${e.toString()}';
      });
      _showErrorSnackbar(errorMessage!);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'Retry', onPressed: _loadApprovedIDs),
      ),
    );
  }

  void _openPDFViewer(String regNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(regNumber: regNumber),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPrinted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrinted ? Colors.blue.shade100 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPrinted ? 'Printed' : 'Not Printed',
        style: TextStyle(
          color: isPrinted ? Colors.blue.shade800 : Colors.grey.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    final regNumber = student['regNumber']?.toString() ?? 'N/A';
    final fullName = student['fullName']?.toString() ?? 'Unknown';
    final isPrinted = _printingStatus[regNumber] ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openPDFViewer(regNumber),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: CachedNetworkImageProvider(
                  '${AppConfig.baseUrl}/api/student/photo/$regNumber',
                ),
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      regNumber,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Approved',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(isPrinted),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () => _openPDFViewer(regNumber),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approved Student IDs'),
        backgroundColor: Colors.green,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApprovedIDs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadApprovedIDs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No approved IDs found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadApprovedIDs,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApprovedIDs,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: students.length,
        itemBuilder: (context, index) => _buildStudentCard(students[index]),
      ),
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  final String regNumber;

  const PDFViewerPage({super.key, required this.regNumber});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  Uint8List? pdfBytes;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      final bytes = await ApiService.getBinary(
        "api/print/view?regNumber=${widget.regNumber}",
      );
      setState(() {
        pdfBytes = bytes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> downloadPDF() async {
    // You can implement file saving logic here (using path_provider + dart:io)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Download feature coming soon!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID Card: ${widget.regNumber}'),
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text("Error: $errorMessage"))
              : Column(
                children: [
                  Expanded(child: SfPdfViewer.memory(pdfBytes!)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                      onPressed: downloadPDF,
                    ),
                  ),
                ],
              ),
    );
  }
}
