import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:idl_sys_app_v1/pages/config.dart';

class ApprovedIDsPage extends StatefulWidget {
  const ApprovedIDsPage({super.key});

  @override
  State<ApprovedIDsPage> createState() => _ApprovedIDsPageState();
}

class _ApprovedIDsPageState extends State<ApprovedIDsPage> {
  List<Map<String, dynamic>> approvedIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApprovedIds();
  }

  Future<void> fetchApprovedIds() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/admin/approved'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          approvedIds = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load approved IDs');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _printId(String regNumber) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${AppConfig.baseUrl}/api/print/mark-printed/$regNumber',
        ), // adjust route
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Print initiated")));
      } else {
        throw Exception("Failed to print");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error printing: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approved ID Requests"),
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: approvedIds.length,
                itemBuilder: (context, index) {
                  final request = approvedIds[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        '${request['fullName']} (${request['regNumber']})',
                      ),
                      subtitle: Text(
                        'Course: ${request['course']}, Year: ${request['yearOfStudy']}',
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () => _printId(request['regNumber']),
                        icon: const Icon(Icons.print),
                        label: const Text("Print"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
