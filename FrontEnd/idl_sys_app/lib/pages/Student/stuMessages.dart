import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StuMessages extends StatefulWidget {
  final String regNo; // pass this from logged-in student

  const StuMessages({super.key, required this.regNo});

  @override
  State<StuMessages> createState() => _StuMessagesState();
}

class _StuMessagesState extends State<StuMessages> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse(
      //add api from database/admin
      "http://10.0.2.2:8080/api/student/${widget.regNo}/messages",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          messages = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load messages.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Connection error: $e";
        isLoading = false;
      });
    }
  }

  Icon _getIcon(String type) {
    switch (type) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.info_outline, color: Colors.blue);
    }
  }

  void _markAsRead(int index) {
    setState(() {
      messages[index]['read'] = true;
    });
    // TODO: Optionally send PUT /api/messages/{id}/mark-read to backend
  }

  void _showMessageDetail(int index) {
    final msg = messages[index];
    _markAsRead(index);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(msg['title']),
            content: Text(msg['body']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(child: Text(error))
              : messages.isEmpty
              ? const Center(child: Text("No messages yet."))
              : ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isRead = msg['read'] == true;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: _getIcon(msg['type']),
                      title: Text(msg['title']),
                      subtitle: Text(msg['date']),
                      trailing:
                          isRead
                              ? null
                              : const CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.red,
                              ),
                      onTap: () => _showMessageDetail(index),
                    ),
                  );
                },
              ),
    );
  }
}
