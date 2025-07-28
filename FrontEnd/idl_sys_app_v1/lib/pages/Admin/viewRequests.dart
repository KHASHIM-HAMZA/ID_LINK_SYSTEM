import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:idl_sys_app_v1/pages/config.dart';

class viewRequest extends StatefulWidget {
  const viewRequest({super.key});

  @override
  State<viewRequest> createState() => _viewRequestState();
}

class _viewRequestState extends State<viewRequest> {
  List<Map<String, dynamic>> idRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/admin/request'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          idRequests = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load requests");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _handleAction(index, String action) async {
    final request = idRequests[index];
    final regNumber = request['regNumber'];

    try {
      String endpoint =
          action == "Approved"
              ? '${AppConfig.baseUrl}/requests/approve?regNumber=$regNumber'
              : '${AppConfig.baseUrl}/api/admin/requests?regNumber=$regNumber/reject';

      final response = await http.put(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        if (action == "Rejected") {
          // Optional: send rejection feedback message
          await http.post(
            Uri.parse('${AppConfig.baseUrl}/api/messages'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'regNo': request['regNumber'],
              'reply':
                  "Your ID request was rejected. Please check your photo or details and try again.",
            }),
          );
        }

        setState(() {
          idRequests[index]['status'] = action;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request ${action.toLowerCase()}")),
        );
      } else {
        throw Exception("Failed to ${action.toLowerCase()} request");
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Action failed: $e")));
    }
  }

  void _showRequestDetails(int index) {
    final request = idRequests[index];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Request: ${request['fullName']}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reg No: ${request['regNumber']}"),
                Text("Course: ${request['course']}"),
                Text("Year: ${request['yearOfStudy']}"),
                Text("Email: ${request['email']}"),
                Text("Phone: ${request['phoneNo']}"),
                Text("Status: ${request['status']}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => _handleAction(index, "Rejected"),
                child: const Text(
                  "Reject",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => _handleAction(index, "Approved"),
                child: const Text(
                  "Approve",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : idRequests.isEmpty
              ? const Center(child: Text("No new ID requests."))
              : ListView.builder(
                itemCount: idRequests.length,
                itemBuilder: (context, index) {
                  final request = idRequests[index];
                  if (request['status'] != "Pending")
                    return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        "${request['fullName']} (${request['regNumber']})",
                      ),
                      subtitle: Text(
                        "Course: ${request['course']} | Year: ${request['yearOfStudy']}",
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => _showRequestDetails(index),
                    ),
                  );
                },
              ),
    );
  }
}
