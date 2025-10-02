import 'package:flutter/material.dart';
import 'package:idl_sys_app_v1/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminLossReportsPage extends StatefulWidget {
  const AdminLossReportsPage({super.key});

  @override
  _AdminLossReportsPageState createState() => _AdminLossReportsPageState();
}

class _AdminLossReportsPageState extends State<AdminLossReportsPage> {
  bool isLoading = true;
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.get('/api/admin/loss-reports');
      setState(() {
        reports = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch reports: $e')));
    }
  }

  Future<void> openPdf(String url) async {
    final fullUrl = '${ApiService.baseUrl}/$url';
    if (await canLaunch(fullUrl)) {
      await launch(fullUrl);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open PDF')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loss Reports'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchReports),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : reports.isEmpty
              ? const Center(child: Text('No reports submitted yet'))
              : ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(report['regNumber'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report['description'] ?? ''),
                          Text('Submitted: ${report['createdAt']}'),
                        ],
                      ),
                      trailing:
                          report['pdfPath'] != null
                              ? IconButton(
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                ),
                                onPressed: () => openPdf(report['pdfPath']),
                              )
                              : null,
                    ),
                  );
                },
              ),
    );
  }
}
