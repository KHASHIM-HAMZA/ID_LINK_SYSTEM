import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        Uri.parse('http://your-server/api/ids/approved'),
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

  void _printId(String regNo) async {
    try {
      final response = await http.post(
        Uri.parse('http://your-server/api/ids/print/$regNo'), // adjust route
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
                      title: Text('${request['name']} (${request['regNo']})'),
                      subtitle: Text(
                        'Course: ${request['course']}, Year: ${request['year']}',
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () => _printId(request['regNo']),
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
